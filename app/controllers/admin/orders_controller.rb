class Admin::OrdersController < Admin::BaseController
  DEFAULT_PER_PAGE = 15

  before_action :load_order,
                only: %i(show update_status cancel confirm process_order
deliver)
  before_action :set_filter_options, only: [:index]

  # GET /admin/orders
  def index
    orders = Order.includes(:user, :order_items)
                  .order(created_at: :desc)

    # Apply filters
    orders = apply_filters(orders)

    @pagy, @orders = pagy(orders,
                          items: params[:per_page] || DEFAULT_PER_PAGE)

    # Stats for dashboard
    @total_orders = Order.count
    @pending_orders = Order.status_pending.count
    @confirmed_orders = Order.status_confirmed.count
    @delivered_orders = Order.status_delivered.count
  end

  # GET /admin/orders/:id
  def show
    @order_items = @order.order_items.includes(:product, :variant)
    @status_histories = @order.order_status_histories.includes(:admin_user)
                              .order(changed_at: :desc)
  end

  # PATCH /admin/orders/:id/confirm
  def confirm
    if @order.can_be_confirmed?
      if @order.confirm!
        create_status_history("confirmed", t(".confirmed_by_admin"))
        flash[:success] =
          t(".confirm_success", order_number: @order.order_number)
      else
        flash[:danger] = t(".confirm_failed")
      end
    else
      flash[:danger] = t(".cannot_confirm")
    end

    redirect_to admin_order_path(@order)
  end

  # PATCH /admin/orders/:id/deliver
  def deliver
    if @order.can_be_delivered?
      if @order.deliver!
        create_status_history("delivered", t(".delivered_by_admin"))
        flash[:success] =
          t(".deliver_success", order_number: @order.order_number)
      else
        flash[:danger] = t(".deliver_failed")
      end
    else
      flash[:danger] = t(".cannot_deliver")
    end

    redirect_to admin_order_path(@order)
  end

  # PATCH /admin/orders/:id/process
  def process_order
    if @order.can_be_processed?
      if @order.process!
        create_status_history("processing", t(".processed_by_admin"))
        flash[:success] =
          t(".process_success", order_number: @order.order_number)
      else
        flash[:danger] = t(".process_failed")
      end
    else
      flash[:danger] = t(".cannot_process")
    end

    redirect_to admin_order_path(@order)
  end

  # PATCH /admin/orders/:id/update_status
  def update_status
    new_status = params[:status]
    reason = params[:reason]

    if valid_status_transition?(new_status)
      if update_order_status(new_status, reason)
        flash[:success] = t(".status_update_success")
      else
        flash[:danger] = t(".status_update_failed")
      end
    else
      flash[:danger] = t(".invalid_status_transition")
    end

    redirect_to admin_order_path(@order)
  end

  # PATCH /admin/orders/:id/cancel
  def cancel # rubocop:disable Metrics/AbcSize
    reason = params[:reason]

    if reason.blank?
      flash[:danger] = t(".cancel_reason_required")
      redirect_to admin_order_path(@order)
      return
    end

    if @order.can_be_cancelled?
      if @order.cancel!(reason)
        create_status_history("cancelled", reason)
        flash[:success] =
          t(".cancel_success", order_number: @order.order_number)
      else
        flash[:danger] = t(".cancel_failed")
      end
    else
      flash[:danger] = t(".cannot_cancel")
    end

    redirect_to admin_order_path(@order)
  end

  private

  def load_order
    @order = Order.find_by(id: params[:id])
    return if @order

    flash[:danger] = t(".order_not_found")
    redirect_to admin_orders_path
  end

  def apply_filters orders
    orders = filter_by_status(orders)
    orders = filter_by_payment_method(orders)
    orders = filter_by_date_range(orders)
    filter_by_total_amount(orders)
  end

  def filter_by_status orders
    return orders if params[:status].blank?

    orders.where(status: params[:status])
  end

  def filter_by_payment_method orders
    return orders if params[:payment_method].blank?

    orders.where(payment_method: params[:payment_method])
  end

  def filter_by_date_range orders
    unless params[:start_date].present? && params[:end_date].present?
      return orders
    end

    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  rescue Date::Error
    orders
  end

  def filter_by_total_amount orders
    unless params[:min_amount].present? || params[:max_amount].present?
      return orders
    end

    if params[:min_amount].present?
      orders = orders.where("total_amount >= ?",
                            params[:min_amount])
    end
    if params[:max_amount].present?
      orders = orders.where("total_amount <= ?",
                            params[:max_amount])
    end
    orders
  end

  def valid_status_transition? new_status
    case @order.status.to_sym
    when :pending
      %w(processing cancelled).include?(new_status)
    when :processing
      %w(confirmed cancelled).include?(new_status)
    when :confirmed
      %w(delivered).include?(new_status)
    else
      false
    end
  end

  def update_order_status new_status, reason
    case new_status
    when "processing"
      @order.process!
    when "confirmed"
      @order.confirm!
    when "delivered"
      @order.deliver!
    when "cancelled"
      return false if reason.blank?

      @order.cancel!(reason)
    else
      return false
    end

    create_status_history(new_status, reason)
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def create_status_history status, reason = nil
    @order.order_status_histories.create!(
      status:,
      note: reason,
      admin_user: current_user,
      changed_at: Time.current
    )
  end

  def set_filter_options
    @status_options = Order.statuses.keys.map do |status|
      [t("orders.status.#{status}"), status]
    end
    @payment_method_options = Order.payment_methods.keys.map do |method|
      [t("orders.payment_method.#{method}"), method]
    end
  end
end
