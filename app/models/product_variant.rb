class ProductVariant < ApplicationRecord
  PERMITTED_PARAMS = %i(name price stock_quantity options_json is_active).freeze

  # Relationships
  belongs_to :product, class_name: Product.name

  # Validations
  validates :sku, presence: true, uniqueness: true, length: {maximum: 100}
  validates :stock_quantity, presence: true,
numericality: {greater_than_or_equal_to: 0}
  validates :price, numericality: {greater_than: 0}, allow_nil: true

  # Callbacks
  before_validation :generate_sku

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :with_stock, -> {where("stock_quantity > 0")}

  # Helper methods
  def current_price
    price.presence || product.base_price
  end

  def in_stock?
    stock_quantity.positive?
  end

  def options
    return {} if options_json.blank?

    JSON.parse(options_json)
  rescue JSON::ParserError
    {}
  end

  def options= value
    self.options_json = value.is_a?(Hash) ? value.to_json : value
  end

  private

  def generate_sku
    return if sku.present?

    base_sku = product&.sku || "PROD#{product&.id}"
    timestamp = Time.current.to_i
    self.sku = "#{base_sku}-VAR-#{timestamp}"
  end
end
