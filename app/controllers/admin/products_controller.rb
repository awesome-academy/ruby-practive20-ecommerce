class Admin::ProductsController < Admin::BaseController
  PRODUCTS_INDEX_PRELOAD = %i(categories brand).freeze
  PRODUCTS_INDEX_PRELOAD_WITH_IMAGES = [
    :categories, :brand,
    {images_attachments: :blob}
  ].freeze

  before_action :load_product,
                only: %i(show edit update destroy toggle_status toggle_featured)
  before_action :load_categories, only: %i(new edit create update)
  before_action :load_brands, only: %i(new edit create update)

  # GET /admin/products
  def index
    filtered_scope = filtered_products.includes(
      PRODUCTS_INDEX_PRELOAD_WITH_IMAGES
    )
    @pagy, @products = pagy(filtered_scope, items: params[:per_page] || 20)
    @categories = Category.order(:name)
    @brands = Brand.all
  end

  # GET /admin/products/:id
  def show
    # @product loaded by before_action
  end

  # GET /admin/products/new
  def new
    @product = Product.new
  end

  # GET /admin/products/:id/edit
  def edit
    # @product loaded by before_action
  end

  # POST /admin/products
  def create
    @product = Product.new(product_params)

    if @product.save
      flash[:success] = t(".success")
      redirect_to admin_product_path(@product)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/products/:id
  def update
    if @product.update(product_params)
      flash[:success] = t(".success")
      redirect_to admin_product_path(@product)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/products/:id
  def destroy
    if @product.destroy
      flash[:success] = t(".success")
    else
      flash[:danger] = t(".error")
    end
    redirect_to admin_products_path
  end

  # PATCH /admin/products/:id/toggle_status
  def toggle_status
    @product.toggle_status!
    status_text = if @product.is_active?
                    t("admin.status.active")
                  else
                    t("admin.status.inactive")
                  end
    flash[:success] = t(".success", status: status_text)
    redirect_back(fallback_location: admin_products_path)
  end

  # PATCH /admin/products/:id/toggle_featured
  def toggle_featured
    @product.update!(is_featured: !@product.is_featured)
    featured_text = if @product.is_featured?
                      t("controllers.admin.products.featured.yes")
                    else
                      t("controllers.admin.products.featured.no")
                    end
    flash[:success] = t(".success", featured: featured_text)
    redirect_back(fallback_location: admin_products_path)
  end

  # PUT /admin/products/sort
  def sort
    # Position sorting not implemented yet - products table doesn't have
    # position column
  end

  # DELETE /admin/products/:id/remove_image/:image_id
  def remove_image
    product = Product.find(params[:id])
    image = product.images.find(params[:image_id])

    if image.purge
      flash[:success] = t(".image_removed")
    else
      flash[:danger] = t(".image_remove_error")
    end

    redirect_to edit_admin_product_path(product)
  end

  private

  def load_product
    @product = Product.find_by(id: params[:id])
    return if @product

    flash[:danger] = t("admin.products.not_found")
    redirect_to admin_products_path
  end

  def load_categories
    @categories = Category.active.order(:name)
  end

  def load_brands
    @brands = Brand.active.order(:name)
  end

  def product_params
    permitted_params =
      Product::PERMITTED_PARAMS + [category_ids: [], images: []]
    params.require(:product).permit(permitted_params)
  end

  def filtered_products
    products = Product.includes(:categories, :brand)
    products = apply_category_filter(products)
    products = apply_brand_filter(products)
    products = apply_status_filter(products)
    products = apply_featured_filter(products)
    products = apply_search_filter(products)
    apply_sort_filter(products)
  end

  def apply_category_filter products
    return products if params[:category_id].blank?

    category = Category.find(params[:category_id])
    category_ids = [category.id]
    category_ids += category.children.pluck(:id) if category.children.any?
    products.joins(:categories).where(categories: {id: category_ids})
  end

  def apply_brand_filter products
    return products if params[:brand_id].blank?

    products.where(brand: params[:brand_id])
  end

  def apply_status_filter products
    case params[:status]
    when "active" then products.active
    when "inactive" then products.inactive
    when "low_stock" then products.low_stock
    when "out_of_stock" then products.out_of_stock
    else products
    end
  end

  def apply_featured_filter products
    case params[:featured]
    when "featured" then products.where(is_featured: true)
    when "not_featured" then products.where(is_featured: false)
    else products
    end
  end

  def apply_search_filter products
    return products if params[:search].blank?

    search_term = "%#{params[:search]}%"
    products.where("name LIKE ? OR sku LIKE ?", search_term, search_term)
  end

  def apply_sort_filter products
    case params[:sort]
    when "name_asc" then products.order(:name)
    when "name_desc" then products.order(name: :desc)
    when "price_asc" then products.order(:price)
    when "price_desc" then products.order(price: :desc)
    when "stock_asc" then products.order(:stock_quantity)
    when "stock_desc" then products.order(stock_quantity: :desc)
    when "created_asc" then products.order(:created_at)
    when "created_desc" then products.order(created_at: :desc)
    else products.order(:created_at)
    end
  end
end
