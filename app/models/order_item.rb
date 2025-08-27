class OrderItem < ApplicationRecord
  # Constants
  PERMITTED_PARAMS = %i(
    order_id product_id variant_id product_name product_sku variant_name
    unit_price quantity total_price
  ).freeze

  # Associations
  belongs_to :order, class_name: Order.name
  belongs_to :product, class_name: Product.name
  belongs_to :variant, class_name: ProductVariant.name, optional: true

  # Validations
  validates :product_name, presence: true, length: {maximum: 255}
  validates :product_sku, length: {maximum: 100}
  validates :variant_name, length: {maximum: 255}
  validates :unit_price, presence: true, numericality: {greater_than: 0}
  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :total_price, presence: true, numericality: {greater_than: 0}

  # Callbacks
  before_save :calculate_total_price

  # Instance methods
  def display_name
    if variant_name.present?
      "#{product_name} - #{variant_name}"
    else
      product_name
    end
  end

  def display_sku
    variant&.sku || product_sku
  end

  private

  def calculate_total_price
    self.total_price = unit_price * quantity
  end
end
