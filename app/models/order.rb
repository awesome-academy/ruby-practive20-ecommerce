class Order < ApplicationRecord
  # Constants
  PERMITTED_PARAMS = %i(
    user_id recipient_name recipient_phone delivery_address note
    payment_method shipping_method subtotal_amount shipping_fee total_amount
  ).freeze

  # Enums
  enum status: {
    pending_confirmation: 0,
    confirmed: 1,
    processing: 2,
    shipping: 3,
    completed: 4,
    cancelled: 5
  }, _prefix: true

  enum payment_method: {
    cod: 0,
    bank_transfer: 1,
    ewallet: 2
  }, _prefix: true

  enum shipping_method: {
    standard: 0,
    express: 1,
    same_day: 2
  }, _prefix: true

  enum payment_status: {
    unpaid: 0,
    paid: 1,
    failed: 2,
    refunded: 3
  }, _prefix: true

  # Associations
  belongs_to :user, optional: true, class_name: User.name
  has_many :order_items, dependent: :destroy, class_name: OrderItem.name
  has_many :products, through: :order_items, class_name: Product.name

  # Validations
  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :payment_method, presence: true
  validates :shipping_method, presence: true
  validates :payment_status, presence: true
  validates :recipient_name, presence: true, length: {maximum: 255}
  validates :recipient_phone, presence: true, length: {maximum: 30}
  validates :delivery_address, presence: true
  validates :subtotal_amount, :shipping_fee, :total_amount,
            presence: true, numericality: {greater_than_or_equal_to: 0}

  # Callbacks
  before_validation :generate_order_number, on: :create
  before_save :calculate_total_amount
  after_update :update_status_timestamps

  # Scopes
  scope :recent, -> {order(created_at: :desc)}
  scope :by_status, ->(status) {where(status:) if status.present?}
  scope :by_user, ->(user) {where(user:)}
  scope :created_between, ->(start_date, end_date) { # rubocop:disable Layout/SpaceInsideBlockBraces
    where(created_at: start_date..end_date)
  }
  scope :completed, -> {where(status: :completed)}

  # Instance methods
  def can_be_cancelled?
    status_pending_confirmation?
  end

  def can_be_confirmed?
    status_pending_confirmation?
  end

  def can_be_processed?
    status_confirmed?
  end

  def can_be_shipped?
    status_processing?
  end

  def can_be_completed?
    status_shipping?
  end

  def total_items
    order_items.sum(:quantity)
  end

  def confirm!
    return false unless can_be_confirmed?

    update!(status: :confirmed, confirmed_at: Time.current)
  end

  def process!
    return false unless can_be_processed?

    update!(status: :processing, processing_at: Time.current)
  end

  def ship!
    return false unless can_be_shipped?

    update!(status: :shipping, shipping_at: Time.current)
  end

  def complete!
    return false unless can_be_completed?

    transaction do
      update!(status: :completed, completed_at: Time.current)
      # Update product sold counts
      order_items.includes(:product).find_each do |item|
        item.product.increment!(:sold_count, item.quantity)
      end
    end
  end

  def cancel! reason = nil
    return false unless can_be_cancelled?

    transaction do
      update!(
        status: :cancelled,
        cancelled_at: Time.current,
        cancelled_reason: reason
      )
      # Restore stock quantities
      restore_stock_quantities!
    end
  end

  def status_display
    I18n.t("models.order.statuses.#{status}")
  end

  def payment_method_display
    I18n.t("models.order.payment_methods.#{payment_method}")
  end

  def shipping_method_display
    I18n.t("models.order.shipping_methods.#{shipping_method}")
  end

  def payment_status_display
    I18n.t("models.order.payment_statuses.#{payment_status}")
  end

  private

  def generate_order_number # rubocop:disable Metrics/AbcSize
    return if order_number.present?

    loop do
      prefix = Settings.order.number.prefix
      date_part = Time.current.strftime(Settings.order.number.date_format)
      random_part = SecureRandom.hex(Settings.order.number.random_length).upcase
      self.order_number = "#{prefix}#{date_part}#{random_part}"
      break unless self.class.exists?(order_number:)
    end
  end

  def calculate_total_amount
    self.total_amount = subtotal_amount + shipping_fee
  end

  def update_status_timestamps # rubocop:disable Metrics/AbcSize
    case status.to_sym
    when :confirmed
      self.confirmed_at = Time.current if confirmed_at.blank?
    when :processing
      self.processing_at = Time.current if processing_at.blank?
    when :shipping
      self.shipping_at = Time.current if shipping_at.blank?
    when :completed
      self.completed_at = Time.current if completed_at.blank?
    when :cancelled
      self.cancelled_at = Time.current if cancelled_at.blank?
    end
  end

  def restore_stock_quantities!
    order_items.includes(:product, :variant).find_each do |item|
      if item.variant
        item.variant.increment!(:stock_quantity, item.quantity)
      else
        item.product.increment!(:stock_quantity, item.quantity)
      end
    end
  end

  class << self
    def create_from_cart! cart, order_params # rubocop:disable Metrics/AbcSize
      transaction do
        order = create!(order_params.merge(
                          subtotal_amount: cart.subtotal_amount,
                          shipping_fee: calculate_shipping_fee(
                            order_params[:shipping_method]
                          )
                        ))

        cart.cart_items.includes(:product, :variant).find_each do |cart_item|
          order.order_items.create!(
            product: cart_item.product,
            variant: cart_item.variant,
            product_name: cart_item.product.name,
            product_sku: cart_item.variant&.sku || cart_item.product.sku,
            variant_name: cart_item.variant&.name,
            unit_price: cart_item.current_price,
            quantity: cart_item.quantity,
            total_price: cart_item.total_price
          )

          # Decrease stock
          if cart_item.variant
            cart_item.variant.decrement!(:stock_quantity, cart_item.quantity)
          else
            cart_item.product.decrement!(:stock_quantity, cart_item.quantity)
          end
        end

        # Mark cart as ordered
        cart.update!(status: :ordered)
        order
      end
    end

    private

    def calculate_shipping_fee shipping_method
      case shipping_method.to_s
      when "standard"
        Settings.shipping.fees.standard
      when "express"
        Settings.shipping.fees.express
      when "same_day"
        Settings.shipping.fees.same_day
      else
        Settings.shipping.fees.standard # Default to standard
      end
    end
  end
end
