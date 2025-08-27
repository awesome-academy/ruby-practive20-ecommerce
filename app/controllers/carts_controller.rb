class CartsController < ApplicationController
  include CartConcern

  before_action :load_cart
  before_action :load_product, only: [:add_item]
  before_action :load_cart_item, only: %i(update_item destroy_item)

  # GET /cart
  def show
    @cart_items = @cart.cart_items.includes(:product, :variant)
    @suggested_products = suggested_products
  end

  # POST /cart/add
  def add_item # rubocop:disable Metrics/AbcSize
    quantity = params[:quantity].to_i

    @cart.add_product(@product, variant: nil, quantity:)

    # Calculate updated values
    cart_total = @cart.total_amount
    cart_items_count = @cart.total_items

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: t(".item_added_success"),
          cart_total:,
          cart_items_count:
        }
      end
      format.html {redirect_to cart_path, notice: t(".item_added_success")}
    end
  rescue StandardError
    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".add_item_error")},
               status: :unprocessable_entity
      end
      format.html do
        redirect_to request.referer || products_path,
                    alert: t(".add_item_error")
      end
    end
  end

  # PATCH /cart/items/:id
  def update_item # rubocop:disable Metrics/AbcSize
    quantity = params[:quantity].to_i

    @cart_item.update!(quantity:)

    # Calculate updated values
    item_total = @cart_item.quantity * @cart_item.current_price
    cart_total = @cart.total_amount
    cart_items_count = @cart.total_items

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: t(".cart_updated_success"),
          item_total:,
          cart_total:,
          cart_items_count:
        }
      end
      format.html {redirect_to cart_path, notice: t(".cart_updated_success")}
    end
  rescue StandardError
    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".update_item_error")},
               status: :unprocessable_entity
      end
      format.html {redirect_to cart_path, alert: t(".update_item_error")}
    end
  end

  # DELETE /cart/items/:id
  def destroy_item
    @cart_item.destroy

    # Calculate updated values
    cart_total = @cart.total_amount
    cart_items_count = @cart.total_items

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: t(".item_removed_success"),
          cart_total:,
          cart_items_count:
        }
      end
      format.html {redirect_to cart_path, notice: t(".item_removed_success")}
    end
  rescue StandardError
    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".remove_item_error")},
               status: :unprocessable_entity
      end
      format.html {redirect_to cart_path, alert: t(".remove_item_error")}
    end
  end

  # DELETE /cart/clear
  def clear
    ActiveRecord::Base.transaction do
      @cart.cart_items.destroy_all
    end

    respond_to do |format|
      format.json do
        render json: {success: true,
                      message: t(".cart_cleared_success")}
      end
      format.html {redirect_to cart_path, notice: t(".cart_cleared_success")}
    end
  rescue StandardError
    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".clear_cart_error")},
               status: :unprocessable_entity
      end
      format.html {redirect_to cart_path, alert: t(".clear_cart_error")}
    end
  end

  private

  def load_product
    @product = Product.find_by(id: params[:product_id])

    return if @product

    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".product_not_found")},
               status: :not_found
      end
      format.html do
        redirect_to products_path, alert: t(".product_not_found")
      end
    end
  end

  def load_cart_item
    @cart_item = @cart.cart_items.find_by(id: params[:id])
    return if @cart_item

    respond_to do |format|
      format.json do
        render json: {success: false, message: t(".cart_item_not_found")},
               status: :not_found
      end
      format.html do
        redirect_to cart_path, alert: t(".cart_item_not_found")
      end
    end
  end

  def suggested_products
    return Product.none if @cart.empty?

    # Get category IDs directly from cart products to avoid N+1
    category_ids = @cart.cart_items
                        .joins(product: :product_categories)
                        .pluck("product_categories.category_id")
                        .uniq

    return Product.none if category_ids.empty?

    # Get product IDs to exclude
    cart_product_ids = @cart.cart_items.pluck(:product_id)

    Product.active
           .includes(:brand, :categories, images_attachments: :blob)
           .joins(:product_categories)
           .where(product_categories: {category_id: category_ids})
           .where.not(id: cart_product_ids)
           .limit(4)
           .distinct
  end
end
