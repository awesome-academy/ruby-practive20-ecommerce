class Product < ApplicationRecord
  PERMITTED_PARAMS = %i(name short_description description price original_price
                         stock_quantity brand_id active featured sku).freeze

  # Relationships
  belongs_to :brand, class_name: Brand.name, optional: true
  has_many :product_categories, dependent: :destroy,
           class_name: ProductCategory.name
  has_many :categories, through: :product_categories, class_name: Category.name
  has_many :product_variants, dependent: :destroy,
           class_name: ProductVariant.name

  # File attachments
  has_many_attached :images

  # Validations
  validates :name, presence: true,
length: {maximum: Settings.business.max_name_length}
  validates :slug, presence: true, uniqueness: true,
length: {maximum: Settings.business.max_slug_length}
  validates :sku, presence: true, uniqueness: true,
length: {maximum: Settings.business.max_sku_length}
  validates :base_price, presence: true, numericality: {greater_than: 0}
  validates :sale_price, numericality: {greater_than: 0}, allow_nil: true
  validates :stock_quantity, presence: true,
            numericality: {greater_than_or_equal_to: 0}
  validate :sale_price_less_than_base_price
  validate :image_format
  validate :image_size

  # Callbacks
  before_validation :generate_slug_and_sku

  # Scopes
  scope :active, -> {where(is_active: true)}
  scope :inactive, -> {where(is_active: false)}
  scope :featured, -> {where(is_featured: true)}
  scope :latest_first, -> {order(created_at: :desc)}
  scope :by_name, -> {order(:name)}
  scope :with_stock, -> {where("stock_quantity > 0")}
  scope :low_stock, -> do
    where("stock_quantity <= ? AND stock_quantity > 0",
          Settings.business.low_stock_threshold)
  end
  scope :out_of_stock, -> {where(stock_quantity: 0)}
  scope :search_by_name, lambda {|query|
    where("name LIKE ?", "%#{query}%") if query.present?
  }
  scope :search_by_description, lambda {|query|
    if query.present?
      where("description LIKE ? OR short_description LIKE ?",
            "%#{query}%", "%#{query}%")
    end
  }
  scope :current_price_gteq, lambda {|min_price|
    if min_price.present?
      where("COALESCE(sale_price, base_price) >= ?", min_price)
    end
  }
  scope :current_price_lteq, lambda {|max_price|
    if max_price.present?
      where("COALESCE(sale_price, base_price) <= ?", max_price)
    end
  }
  scope :in_price_range, lambda {|min, max|
    scope = all
    scope = scope.current_price_gteq(min) if min.present?
    scope = scope.current_price_lteq(max) if max.present?
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
  scope :by_status, lambda {|status|
    case status
    when "active" then active
    when "inactive" then inactive
    else all
    end
  }
  scope :by_stock_status, lambda {|stock_status|
    case stock_status
    when "in_stock" then with_stock
    when "low_stock" then low_stock
    when "out_of_stock" then out_of_stock
    else all
    end
  }
  scope :by_featured, lambda {|featured_status|
    case featured_status
    when "featured" then featured
    when "not_featured" then where(is_featured: false)
    else all
    end
  }
  scope :sorted_by, lambda {|sort_option|
    case sort_option
    when "name_asc" then order(:name)
    when "name_desc" then order(name: :desc)
    when "price_asc" then order(Arel.sql("COALESCE(sale_price, base_price) ASC")) # rubocop:disable Layout/LineLength
    when "price_desc" then order(Arel.sql("COALESCE(sale_price, base_price) DESC")) # rubocop:disable Layout/LineLength
    when "stock_asc" then order(:stock_quantity)
    when "stock_desc" then order(stock_quantity: :desc)
    when "created_asc" then order(:created_at)
    when "created_desc" then order(created_at: :desc)
    else order(created_at: :desc) # default
    end
  }

  # Search scopes - converted from search_products method
  scope :search_by_query, lambda {|query|
    if query.present?
      search_term = "%#{query}%"
      where(
        "name LIKE ? OR description LIKE ? OR short_description LIKE ?",
        search_term, search_term, search_term
      )
    end
  }

  scope :search_products, lambda {|params|
    scope = all
    scope = scope.search_by_query(params[:query]) if params[:query].present?
    scope = scope.search_by_name(params[:name]) if params[:name].present?
    if params[:description].present?
      scope = scope.search_by_description(params[:description])
    end
    scope
  }

  # Filter scopes - converted from filter_by_params method
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

  # Sort scopes - converted from sort_by_param method
  scope :sort_by_name_asc, -> {order(:name)}
  scope :sort_by_name_desc, -> {order(name: :desc)}
  scope :sort_by_price_asc, -> {order(Arel.sql("COALESCE(sale_price, base_price) ASC"))} # rubocop:disable Layout/LineLength
  scope :sort_by_price_desc, -> {order(Arel.sql("COALESCE(sale_price, base_price) DESC"))} # rubocop:disable Layout/LineLength
  scope :sort_by_newest, -> {order(created_at: :desc)}
  scope :sort_by_oldest, -> {order(created_at: :asc)}
  scope :sort_by_popular, -> {order(view_count: :desc)}
  scope :sort_by_best_selling, -> {order(sold_count: :desc)}

  scope :sort_by_param, lambda {|sort_param|
    case sort_param&.to_s
    when "name_asc" then sort_by_name_asc
    when "name_desc" then sort_by_name_desc
    when "price_asc" then sort_by_price_asc
    when "price_desc" then sort_by_price_desc
    when "newest" then sort_by_newest
    when "oldest" then sort_by_oldest
    when "popular" then sort_by_popular
    when "best_selling" then sort_by_best_selling
    else sort_by_newest # default
    end
  }

  # Helper methods
  def current_price
    sale_price.presence || base_price
  end

  # Compatibility methods for form
  def price
    # Return current selling price (sale_price if on sale, otherwise base_price)
    sale_price.presence || base_price
  end

  def price= value
    if original_price.present?
      # If original_price exists, this is sale_price
      self.sale_price = value
    else
      # If no original_price, this is base_price
      self.base_price = value
    end
  end

  def original_price
    # Return base_price only if sale_price exists (product is on sale)
    return base_price if sale_price.present?

    nil
  end

  def original_price= value
    if value.present? && value.to_f.positive?
      # Set original price and move current price to sale_price
      current_selling_price = price
      self.base_price = value
      self.sale_price = current_selling_price if current_selling_price != value
    else
      # Clear sale - move sale_price back to base_price
      self.base_price = sale_price if sale_price.present?
      self.sale_price = nil
    end
  end

  def active
    is_active
  end

  def active= value
    self.is_active = value
  end

  def featured
    is_featured
  end

  def featured= value
    self.is_featured = value
  end

  def active?
    is_active?
  end

  def featured?
    is_featured?
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

  def low_stock?
    stock_quantity <= Settings.business.low_stock_threshold &&
      stock_quantity.positive?
  end

  def stock_status
    return :out_of_stock if stock_quantity.zero?
    return :low_stock if low_stock?

    :in_stock
  end

  def toggle_status!
    update!(is_active: !is_active)
  end

  def main_image
    images.attached? ? images.first : nil
  end

  # Image helper methods
  def main_image_url
    # Return image_url if present, otherwise fallback to Active Storage
    image_url.presence
  end

  def has_image?
    image_url.present? || images.attached?
  end

  def can_be_deleted?
    # Check if product is referenced in any order_items or cart_items
    !OrderItem.exists?(product_id: id) && !CartItem.exists?(product_id: id)
  end

  # Check if product is available for purchase
  def available_for_purchase?
    active? && in_stock?
  end

  private

  def generate_slug_and_sku
    generate_unique_slug if name.present?
    generate_unique_sku if sku.blank?
  end

  def generate_unique_slug
    base_slug = name.parameterize
    counter = 1
    candidate_slug = base_slug

    loop do
      unless Product.exists?(slug: candidate_slug)
        break self.slug = candidate_slug
      end

      counter += 1
      candidate_slug = "#{base_slug}-#{counter}"
    end
  end

  def generate_unique_sku
    base_sku = if name.present?
                 name.first(Settings.business.sku_prefix_length).upcase
               else
                 Settings.business.default_sku_prefix
               end
    counter = 1

    loop do
      candidate_sku = "#{base_sku}#{counter.to_s.rjust(
        Settings.business.sku_counter_padding, '0'
      )}"
      break self.sku = candidate_sku unless Product.exists?(sku: candidate_sku)

      counter += 1
    end
  end

  def sale_price_less_than_base_price
    return unless sale_price.present? && base_price.present?

    return unless sale_price >= base_price

    errors.add(:sale_price, :less_than_base_price)
  end

  def image_format
    return unless images.attached?

    acceptable_types = Settings.product.allowed_mime_types
    images.each do |image|
      next if acceptable_types.include?(image.blob.content_type)

      errors.add(:images, :invalid_format)
      break
    end
  end

  def image_size
    return unless images.attached?

    max_size = Settings.product.max_image_size.megabytes
    images.each do |image|
      next unless image.blob.byte_size > max_size

      errors.add(:images, :too_large, size: Settings.product.max_image_size)
      break
    end
  end
end
