class Cart < ApplicationRecord
  # Constants
  PERMITTED_PARAMS = %i(user_id session_id status).freeze

  # Enums
  enum status: {active: 0, ordered: 1}, _prefix: true

  # Associations
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy, class_name: CartItem.name
  has_many :products, through: :cart_items, class_name: Product.name

  # Validations
  validates :session_id, presence: true, unless: :user_id?
  validates :status, presence: true
  validate :only_one_active_cart_per_session, if: :status_active?

  # Scopes
  scope :active, -> {where(status: :active)}
  scope :for_user, ->(user) {where(user:)}
  scope :for_session, ->(session_id) {where(session_id:)}

  # Instance methods
  def total_items
    cart_items.sum(:quantity)
  end

  def total_amount
    cart_items.sum do |item|
      item.quantity * item.current_price
    end
  end

  alias total total_amount
  alias subtotal total_amount

  def subtotal_amount
    total_amount
  end

  delegate :empty?, to: :cart_items

  def has_out_of_stock_items?
    cart_items.joins(:product).any? do |item|
      !item.in_stock?
    end
  end

  def add_product product, variant: nil, quantity: 1
    existing_item = cart_items.find_by(
      product:,
      variant:
    )

    if existing_item
      existing_item.increment(:quantity, quantity)
      existing_item.save!
    else
      cart_items.create!(
        product:,
        variant:,
        quantity:
      )
    end
  end

  def remove_product product, variant: nil
    cart_items.find_by(
      product:,
      variant:
    )&.destroy
  end

  def update_item_quantity product, quantity:, variant: nil
    item = cart_items.find_by(
      product:,
      variant:
    )

    return false unless item

    if quantity <= 0
      item.destroy
    else
      item.update!(quantity:)
    end

    true
  end

  def merge_with! other_cart
    return if other_cart == self

    transaction do
      other_cart.cart_items.find_each do |other_item|
        existing_item = cart_items.find_by(
          product: other_item.product,
          variant: other_item.variant
        )

        if existing_item
          existing_item.increment(:quantity, other_item.quantity)
          existing_item.save!
        else
          other_item.update!(cart: self)
        end
      end

      other_cart.destroy!
    end
  end

  private

  def only_one_active_cart_per_session
    return if session_id.blank?

    existing_cart = Cart.where(session_id:, status: :active)
                        .where.not(id:)
                        .first

    return unless existing_cart

    errors.add(:session_id, :already_has_active_cart)
  end

  class << self
    def find_or_create_for_user user
      find_or_create_by(user:, status: :active)
    end

    def find_or_create_for_session session_id
      find_or_create_by(session_id:, status: :active)
    end

    def current_cart user: nil, session_id: nil
      if user
        find_or_create_for_user(user)
      elsif session_id
        find_or_create_for_session(session_id)
      else
        raise ArgumentError, "Either user or session_id must be provided"
      end
    end
  end
end
