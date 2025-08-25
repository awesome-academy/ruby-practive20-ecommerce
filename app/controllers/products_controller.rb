class ProductsController < ApplicationController
  PRODUCTS_INDEX_PRELOAD = %i(brand categories).freeze

  before_action :load_product, only: [:show]
  before_action :load_filter_data, only: [:index]

  # GET /products
  def index
    products_scope = Product.includes(PRODUCTS_INDEX_PRELOAD)
                            .active
                            .search_products(search_params)
                            .filter_by_params(filter_params)
                            .sort_by_param(params[:sort])

    @pagy, @products = pagy(products_scope)
    @total_count = @pagy.count
  end

  # GET /products/:id
  def show
    category_ids = @product.categories.pluck(:id)
    @related_products = Product.active
                               .includes(PRODUCTS_INDEX_PRELOAD)
                               .joins(:categories)
                               .where(categories: {id: category_ids})
                               .where.not(id: @product.id)
                               .limit(Settings.business.related_products_limit)

    # Increment view count
    Product.increment_counter(:view_count, @product.id)
  end

  private

  def load_product
    @product = Product.find_by(id: params[:id])
    return if @product&.is_active?

    flash[:danger] = t("products.not_found")
    redirect_to products_path
  end

  def load_filter_data
    @brands = Brand.active.order(:name)
    @categories = Category.active.ordered
    @root_categories = Category.active.root_categories.ordered
  end

  def search_params
    {
      query: params[:q],
      name: params[:name],
      description: params[:description]
    }
  end

  def filter_params
    {
      category_id: params[:category_id],
      brand_id: params[:brand_id],
      min_price: params[:min_price],
      max_price: params[:max_price],
      in_stock: params[:in_stock]
    }
  end
end
