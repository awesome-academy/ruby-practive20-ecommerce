class Admin::ProductsController < Admin::BaseController
  PRODUCTS_INDEX_PRELOAD = %i(categories brand).freeze
  PRODUCTS_INDEX_PRELOAD_WITH_IMAGES = [
    :categories, :brand,
    {images_attachments: :blob}
  ].freeze
  DEFAULT_PER_PAGE = 20

  before_action :load_product,
                only: %i(show edit update destroy toggle_status toggle_featured
                        remove_image duplicate)
  before_action :load_categories, only: %i(new edit create update)
  before_action :load_brands, only: %i(new edit create update)
  before_action :load_image, only: %i(remove_image)

  # GET /admin/products
  def index
    filtered_scope = filtered_products.includes(
      PRODUCTS_INDEX_PRELOAD_WITH_IMAGES
    )
    @pagy, @products = pagy(filtered_scope,
                            items: params[:per_page] || DEFAULT_PER_PAGE)
    @categories = Category.order(:name)
    @brands = Brand.all
  end

  # GET /admin/products/:id
  def show; end

  # GET /admin/products/new
  def new
    @product = Product.new
  end

  # GET /admin/products/:id/edit
  def edit; end

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
      # Attach new images if any
      attach_new_images if params[:product][:images].present?

      flash[:success] = t(".success")
      redirect_to admin_product_path(@product)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/products/:id
  def destroy
    if @product.can_be_deleted?
      if @product.destroy
        flash[:success] = t(".success")
      else
        flash[:danger] = t(".error")
      end
    else
      flash[:warning] = t(".cannot_delete_has_orders")
    end
    redirect_to admin_products_path
  end

  # PATCH /admin/products/:id/toggle_status
  def toggle_status
    if @product.update(is_active: !@product.is_active)
      status_text = if @product.is_active?
                      t("admin.status.active")
                    else
                      t("admin.status.inactive")
                    end
      flash[:success] = t(".success", status: status_text)
    else
      flash[:danger] = t(".error")
    end
    redirect_back(fallback_location: admin_products_path)
  end

  # PATCH /admin/products/:id/toggle_featured
  def toggle_featured
    if @product.update(is_featured: !@product.is_featured)
      featured_text = if @product.is_featured?
                        t("admin.featured.yes")
                      else
                        t("admin.featured.no")
                      end
      flash[:success] = t(".success", featured: featured_text)
    else
      flash[:danger] = t(".error")
    end
    redirect_back(fallback_location: admin_products_path)
  end

  # PUT /admin/products/sort
  def sort
    # Position sorting not implemented yet - products table doesn't have
    # position column
  end

  # POST /admin/products/:id/duplicate
  def duplicate # rubocop:disable Metrics/AbcSize
    Product.transaction do
      duplicated_product = @product.dup

      # Update name and SKU to make them unique
      duplicated_product.name = "#{@product.name} (Copy)"
      duplicated_product.sku = nil # Will auto-generate in model callback
      duplicated_product.slug = nil # Will auto-generate in model callback

      # Set as inactive by default
      duplicated_product.is_active = false
      duplicated_product.is_featured = false

      if duplicated_product.save
        # Copy categories
        duplicated_product.category_ids = @product.category_ids

        # Copy images if they exist
        if @product.images.attached?
          @product.images.each do |image|
            duplicated_product.images.attach(image.blob)
          end
        end

        flash[:success] = t(".success", name: duplicated_product.name)
        redirect_to edit_admin_product_path(duplicated_product)
      else
        flash[:danger] = t(".error")
        redirect_to admin_product_path(@product)
      end
    end
  rescue StandardError => e
    Rails.logger.error "Product duplication failed: #{e.message}"
    flash[:danger] = t(".error")
    redirect_to admin_product_path(@product)
  end

  # DELETE /admin/products/:id/remove_image/:image_id
  def remove_image
    if @image.purge
      flash[:success] = t(".image_removed")
    else
      flash[:danger] = t(".image_remove_error")
    end

    redirect_to edit_admin_product_path(@product)
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
    # Exclude images from mass assignment to handle them separately
    permitted_params = Product::PERMITTED_PARAMS + [category_ids: []]

    # Only include images for create action, not update
    permitted_params += [images: []] if action_name == "create"

    params.require(:product).permit(permitted_params)
  end

  def attach_new_images
    return if params[:product][:images].blank?

    params[:product][:images].each do |image|
      next if image.blank?

      @product.images.attach(image)
    end
  end

  def filtered_products # rubocop:disable Metrics/AbcSize
    Product.includes(:categories, :brand)
           .by_category(params[:category_id])
           .by_brand(params[:brand_id])
           .by_status(params[:status])
           .by_stock_status(params[:stock_status])
           .by_featured(params[:featured])
           .in_price_range(params[:min_price], params[:max_price])
           .search_by_query(params[:search])
           .sorted_by(params[:sort])
  end

  def load_image
    @image = @product.images.find {|img| img.signed_id == params[:image_id]}
    return if @image

    flash[:danger] = t("admin.products.image_not_found")
    redirect_to edit_admin_product_path(@product)
  end
end
