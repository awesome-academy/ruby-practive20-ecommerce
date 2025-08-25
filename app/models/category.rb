class Category < ApplicationRecord
  PERMITTED_PARAMS = %i(name description parent_id position is_active
meta_title meta_description).freeze

  # Self-referential relationship for nested categories
  belongs_to :parent, class_name: Category.name, optional: true
  has_many :children, class_name: Category.name, foreign_key: "parent_id",
           dependent: :destroy

  # Many-to-many with products
  has_many :product_categories, dependent: :destroy,
           class_name: ProductCategory.name
  has_many :products, through: :product_categories, class_name: Product.name

  # File attachments
  has_one_attached :icon

  # Validations
  validates :name, presence: true, length: {maximum: 255}
  validates :slug, presence: true, uniqueness: true, length: {maximum: 255}
  validates :position, presence: true,
            numericality: {greater_than_or_equal_to: 0}
  validate :cannot_be_parent_of_itself

  # Callbacks
  before_validation :generate_slug

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :inactive, -> {where(is_active: false)}
  scope :root_categories, -> {where(parent_id: nil)}
  scope :ordered, -> {order(:position, :name)}
  scope :search_by_name, lambda {|query|
    where("name LIKE ?", "%#{query}%") if query.present?
  }
  scope :by_status, lambda {|status|
    case status
    when "active" then active
    when "inactive" then inactive
    else all
    end
  }
  scope :by_parent, lambda {|parent_id|
    case parent_id
    when "root" then where(parent_id: nil)
    when nil, "", "all" then all
    else where(parent_id:)
    end
  }
  scope :with_products_count, -> do
    left_joins(:product_categories)
      .group(:id)
      .select("categories.*, COUNT(product_categories.id) as products_count")
  end
  scope :sorted_by, lambda {|sort_option|
    case sort_option
    when "position" then order(:position, :name)
    when "name_asc" then order(:name)
    when "name_desc" then order(name: :desc)
    when "created_desc" then order(created_at: :desc)
    when "created_asc" then order(created_at: :asc)
    else order(:position, :name) # default
    end
  }

  def products_count
    @products_count ||= products.count
  end

  def total_products_count
    # Sum of all products of this category and all children
    count = products.count
    children.each do |child|
      count += child.total_products_count
    end
    count
  end

  def can_be_deleted?
    products_count.zero? && children.empty?
  end

  def toggle_status!
    update!(is_active: !is_active)
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def cannot_be_parent_of_itself
    return if parent_id.blank?

    errors.add(:parent_id, :cannot_be_self) if parent_id == id

    # Check for circular reference
    current_parent = parent
    while current_parent
      if current_parent.id == id
        errors.add(:parent_id, :circular_reference)
        break
      end
      current_parent = current_parent.parent
    end
  end
end
