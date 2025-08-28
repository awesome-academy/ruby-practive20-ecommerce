class CheckoutController < ApplicationController
  include CartConcern

  before_action :load_cart
  before_action :ensure_cart_not_empty, except: [:success]
  before_action :validate_cart_items, except: [:success]
  before_action :require_login_for_checkout, only: %i(new create)
  before_action :set_checkout_data, only: %i(new create)
  before_action :load_order_by_number, only: [:success]

  # GET /checkout
  def new
    @order_form = OrderForm.new

    # Pre-fill user data if logged in
    return unless logged_in?

    @order_form.recipient_name = current_user.name
  end

  # POST /checkout
  def create # rubocop:disable Metrics/AbcSize
    @order_form = OrderForm.new(order_form_params)

    if @order_form.valid?
      begin
        ActiveRecord::Base.transaction do
          # Create order from cart
          @order = Order.create_from_cart!(@cart, build_order_params)

          # Process payment (mock for now - always successful)
          process_payment(@order)

          # Confirm order automatically for COD, or after successful payment
          if @order.payment_method_cod? || @order.payment_status_paid?
            @order.confirm!
          end

          # Clear cart after successful order
          @cart.cart_items.destroy_all
        end

        flash[:success] = t(".order_success", order_number: @order.order_number)
        redirect_to checkout_success_path(@order.order_number)
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:danger] = t(".order_failed")
        Rails.logger.error "Order creation failed: #{e.message}"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:danger] = t(".form_invalid")
      render :new, status: :unprocessable_entity
    end
  end

  # GET /checkout/success/:order_number
  def success
    # Security check, only allow access to own orders or guest orders in session
    return if can_access_order?(@order)

    flash[:danger] = t(".access_denied")
    redirect_to root_path
    nil
  end

  private

  def require_login_for_checkout
    return if logged_in?

    # Store the cart URL so user can return after login to see merged cart
    session[:forwarding_url] = cart_path
    flash[:warning] = t(".login_required")
    redirect_to login_path
  end

  def load_order_by_number
    @order = Order.find_by!(order_number: params[:order_number])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = t(".order_not_found")
    redirect_to root_path
  end

  def build_order_params
    {
      user: logged_in? ? current_user : nil,
      recipient_name: @order_form.recipient_name,
      recipient_phone: @order_form.recipient_phone,
      delivery_address: @order_form.delivery_address,
      note: @order_form.note,
      payment_method: @order_form.payment_method,
      shipping_method: @order_form.shipping_method
    }
  end

  def ensure_cart_not_empty
    return unless @cart.empty?

    flash[:warning] = t(".cart_empty")
    redirect_to cart_path
  end

  def validate_cart_items
    if @cart.has_invalid_items?
      flash[:warning] = t(".cart_items_invalid")
      redirect_to cart_path
    elsif @cart.has_updated_items?
      flash[:warning] = t(".cart_items_changed")
      redirect_to cart_path
    end
  end

  def set_checkout_data
    @cart_items = @cart.cart_items.includes(:product, :variant)
    @subtotal = @cart.subtotal_amount
    @shipping_options = shipping_options
    @payment_methods = payment_method_options
  end

  def shipping_options
    [
      {
        id: :standard,
        name: t(".shipping_methods.standard"),
        price: Settings.shipping.fees.standard,
        description: t(".shipping_methods.standard_desc")
      },
      {
        id: :express,
        name: t(".shipping_methods.express"),
        price: Settings.shipping.fees.express,
        description: t(".shipping_methods.express_desc")
      },
      {
        id: :same_day,
        name: t(".shipping_methods.same_day"),
        price: Settings.shipping.fees.same_day,
        description: t(".shipping_methods.same_day_desc")
      }
    ]
  end

  def payment_method_options
    [
      {
        id: :cod,
        name: t(".payment_methods.cod"),
        description: t(".payment_methods.cod_desc")
      },
      {
        id: :bank_transfer,
        name: t(".payment_methods.bank_transfer"),
        description: t(".payment_methods.bank_transfer_desc")
      },
      {
        id: :ewallet,
        name: t(".payment_methods.ewallet"),
        description: t(".payment_methods.ewallet_desc")
      }
    ]
  end

  def process_payment order
    # Mock payment processing - always successful for now
    case order.payment_method
    when "cod"
      # COD - payment will be collected on delivery
      order.update!(payment_status: :unpaid)
    when "bank_transfer", "ewallet"
      # Mock successful payment
      order.update!(payment_status: :paid)
    end
  end

  def can_access_order? order
    return true if logged_in? && order.user == current_user
    return true if order.user.nil? # Guest order - allow access

    false
  end

  def order_form_params
    params.require(:order_form).permit(
      :recipient_name, :recipient_phone, :delivery_address, :note,
      :payment_method, :shipping_method, :terms_accepted
    )
  end
end
