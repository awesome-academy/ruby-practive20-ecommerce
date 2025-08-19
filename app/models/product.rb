class Product < ApplicationRecord
  PERMITTED_PARAMS = %i(name short_description description base_price sale_price
                         stock_quantity brand_id is_active is_featured).freeze

  # Relationships
  belongs_to :brand, class_name: Brand.name, optional: true
  has_many :product_categories, dependent: :destroy,
           class_name: ProductCategory.name
  has_many :categories, through: :product_categories, class_name: Category.name
  has_many :product_variants, dependent: :destroy,
           class_name: ProductVariant.name

  # Validations
  validates :name, presence: true, length: {maximum: 255}
  validates :slug, presence: true, uniqueness: true, length: {maximum: 255}
  validates :base_price, presence: true, numericality: {greater_than: 0}
  validates :sale_price, numericality: {greater_than: 0}, allow_nil: true
  validates :stock_quantity, presence: true,
            numericality: {greater_than_or_equal_to: 0}
  validate :sale_price_less_than_base_price

  # Callbacks
  before_validation :generate_slug

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :featured, -> {where(is_featured: true)}
  scope :latest_first, -> {order(created_at: :desc)}
  scope :by_name, -> {order(:name)}
  scope :with_stock, -> {where("stock_quantity > 0")}
  scope :search_by_name, lambda {|query|
    where("name LIKE ?", "%#{query}%") if query.present?
  }
  scope :search_by_description, lambda {|query|
    if query.present?
      where("description LIKE ? OR short_description LIKE ?",
            "%#{query}%", "%#{query}%")
    end
  }
  scope :base_price_gteq, lambda {|min_price|
    where("base_price >= ?", min_price) if min_price.present?
  }
  scope :base_price_lteq, lambda {|max_price|
    where("base_price <= ?", max_price) if max_price.present?
  }
  scope :in_price_range, lambda {|min, max|
    scope = all
    scope = scope.base_price_gteq(min) if min.present?
    scope = scope.base_price_lteq(max) if max.present?
    scope
  }
  scope :by_category, lambda {|category_id|
    if category_id.present?
      # Take the selected category and all its child categories
      selected_category = Category.find_by(id: category_id)
      if selected_category
        # Find all category IDs including the current category and its
        # child categories
        category_ids = [selected_category.id] +
                       selected_category.children.pluck(:id)
        joins(:categories).where(categories: {id: category_ids})
      end
    end
  }
  scope :by_brand, lambda {|brand_id|
    where(brand_id:) if brand_id.present?
  }

  # Additional scopes for searching and filtering
  scope :search_products, lambda {|params|
    scope = all

    if params[:query].present?
      query = "%#{params[:query]}%"
      scope = scope.where(
        "name LIKE ? OR description LIKE ? OR short_description LIKE ?",
        query, query, query
      )
    end

    scope = scope.search_by_name(params[:name]) if params[:name].present?
    if params[:description].present?
      scope = scope.search_by_description(params[:description])
    end

    scope
  }

  scope :filter_by_params, lambda {|params|
    scope = all

    if params[:category_id].present?
      scope = scope.by_category(params[:category_id])
    end
    scope = scope.by_brand(params[:brand_id]) if params[:brand_id].present?
    scope = scope.in_price_range(params[:min_price], params[:max_price])
    scope = scope.with_stock if params[:in_stock] == "1"

    scope
  }

  scope :sort_by_param, lambda {|sort_param|
    case sort_param
    when "name_asc"
      order(:name)
    when "name_desc"
      order(name: :desc)
    when "price_asc"
      order(:base_price)
    when "price_desc"
      order(base_price: :desc)
    when "newest"
      order(created_at: :desc)
    when "oldest"
      order(created_at: :asc)
    when "popular"
      order(view_count: :desc)
    when "best_selling"
      order(sold_count: :desc)
    else
      order(created_at: :desc) # default
    end
  }

  # Helper methods
  def current_price
    sale_price.presence || base_price
  end

  def on_sale?
    sale_price.present? && sale_price < base_price
  end

  def discount_percentage
    return 0 unless on_sale?

    ((base_price - sale_price) / base_price * 100).round(0)
  end

  def in_stock?
    stock_quantity.positive?
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def sale_price_less_than_base_price
    return unless sale_price.present? && base_price.present?

    return unless sale_price >= base_price

    errors.add(:sale_price, :less_than_base_price)
  end
end
