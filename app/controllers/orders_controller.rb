class OrdersController < ApplicationController
  before_action :set_order, only: %i(show cancel)
  before_action :ensure_order_access, only: %i(show cancel)

  # GET /orders
  def index
    if logged_in?
      @pagy, @orders = pagy(
        current_user.orders.includes(order_items: :product).recent,
        items: 10
      )
    else
      flash[:warning] = t(".login_required")
      redirect_to login_path
    end
  end

  # GET /orders/:id
  def show
    @order_items = @order.order_items.includes(:product, :variant)
  end

  # PATCH /orders/:id/cancel
  def cancel # rubocop:disable Metrics/AbcSize
    begin
      if @order.can_be_cancelled?
        @order.cancel!(t(".user_cancellation"))
        flash[:success] =
          t(".cancel_success", order_number: @order.order_number)
      else
        flash[:danger] = t(".cancel_failed")
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = t(".cancel_error")
      Rails.logger.error "Order cancellation failed: #{e.message}"
    rescue StandardError => e
      flash[:danger] = t(".unexpected_error")
      Rails.logger.error "Unexpected error during order cancellation:
                          #{e.message}"
    end

    redirect_to @order
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    return if @order

    flash[:danger] = t(".order_not_found")
    redirect_to orders_path
  end

  def ensure_order_access
    return if can_access_order?(@order)

    flash[:danger] = t(".access_denied")
    redirect_to root_path
  end

  def can_access_order? order
    return true if logged_in? && order.user == current_user

    false
  end
end
