class ProductCategory < ApplicationRecord
  # Relationships
  belongs_to :product, class_name: Product.name
  belongs_to :category, class_name: Category.name

  # Validations
  validates :product_id, uniqueness: {scope: :category_id}
end
