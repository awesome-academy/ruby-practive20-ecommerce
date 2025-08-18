class Category < ApplicationRecord
  PERMITTED_PARAMS = %i(name parent_id position).freeze

  # Self-referential relationship for nested categories
  belongs_to :parent, class_name: Category.name, optional: true
  has_many :children, class_name: Category.name, foreign_key: "parent_id",
dependent: :destroy

  # Many-to-many with products
  has_many :product_categories, dependent: :destroy,
class_name: ProductCategory.name
  has_many :products, through: :product_categories, class_name: Product.name

  # Validations
  validates :name, presence: true, length: {maximum: 255}
  validates :slug, presence: true, uniqueness: true, length: {maximum: 255}
  validates :position, presence: true,
numericality: {greater_than_or_equal_to: 0}

  # Callbacks
  before_validation :generate_slug

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :root_categories, -> {where(parent_id: nil)}
  scope :ordered, -> {order(:position, :name)}

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
