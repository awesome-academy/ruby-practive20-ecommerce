class Brand < ApplicationRecord
  PERMITTED_PARAMS = %i(name description logo_url).freeze

  # Relationships
  has_many :products, dependent: :destroy, class_name: Product.name

  # Validations
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :slug, presence: true, uniqueness: true, length: {maximum: 255}

  # Callbacks
  before_validation :generate_slug

  # Scopes
  scope :active, -> do
    joins(:products)
      .where(products: {is_active: true})
      .distinct
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
