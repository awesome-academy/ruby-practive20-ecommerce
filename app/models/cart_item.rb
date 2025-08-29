class CartItem < ApplicationRecord
  # Constants
  PERMITTED_PARAMS = %i(cart_id product_id variant_id quantity).freeze

  # Associations
  belongs_to :cart, class_name: Cart.name
  belongs_to :product, class_name: Product.name
  belongs_to :variant, class_name: ProductVariant.name, optional: true

  # Validations
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :product_id, uniqueness: {
    scope: %i(cart_id variant_id),
    message: I18n.t("models.cart_item.errors.product_already_in_cart")
  }
  validate :product_must_be_active
  validate :variant_must_be_active, if: :variant
  validate :variant_belongs_to_product, if: :variant
  validate :quantity_does_not_exceed_stock

  # Callbacks
  before_save :validate_stock_availability
  before_create :set_cart_snapshot_at
  before_update :set_cart_snapshot_at

  # Instance methods
  def current_price
    if variant
      variant.price || product.current_price
    else
      product.current_price
    end
  end

  def total_price
    quantity * current_price
  end

  def product_name
    if variant
      "#{product.name} - #{variant.name}"
    else
      product.name
    end
  end

  def available_stock
    if variant
      variant.stock_quantity
    else
      product.stock_quantity
    end
  end

  def in_stock?
    available_stock >= quantity
  end

  def stock_sufficient? requested_quantity = quantity
    available_stock >= requested_quantity
  end

  def product_updated_since_cart?
    return false unless cart_snapshot_at
    return false unless product&.updated_at

    product.updated_at > cart_snapshot_at
  end

  private

  def set_cart_snapshot_at
    self.cart_snapshot_at = Time.current
  end

  def product_must_be_active
    return if product&.is_active?

    errors.add(:product, I18n.t("models.cart_item.errors.product_not_active"))
  end

  def variant_must_be_active
    return if variant&.is_active?

    errors.add(:variant, I18n.t("models.cart_item.errors.variant_not_active"))
  end

  def variant_belongs_to_product
    return if variant&.product == product

    errors.add(:variant,
               I18n.t("models.cart_item.errors.variant_not_belong_to_product"))
  end

  def quantity_does_not_exceed_stock
    return if stock_sufficient?

    errors.add(:quantity, I18n.t("models.cart_item.errors.insufficient_stock",
                                 available: available_stock))
  end

  def validate_stock_availability
    return if in_stock?

    errors.add(:base, I18n.t("models.cart_item.errors.out_of_stock"))
    throw :abort
  end
end
