module CartConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart, :cart_items_count, :current_cart_items_count
    before_action :sync_guest_cart_with_user_cart, if: :logged_in?
  end

  private

  def current_cart
    @current_cart ||= if logged_in?
                        Cart.find_or_create_for_user(current_user)
                      else
                        Cart.find_or_create_for_session(cart_session_id)
                      end
  end

  def load_cart
    @cart = current_cart
  end

  def cart_items_count
    current_cart.total_items
  end

  def current_cart_items_count
    current_cart.total_items
  end

  def cart_session_id
    session[:cart_session_id] ||= SecureRandom.uuid
  end

  def sync_guest_cart_with_user_cart
    return if session[:cart_session_id].blank?

    guest_cart = Cart.find_by(session_id: session[:cart_session_id],
                              status: :active)
    return unless guest_cart&.cart_items&.exists?

    user_cart = Cart.find_or_create_for_user(current_user)

    if guest_cart != user_cart
      Rails.logger.info "Merging guest cart #{guest_cart.id} with user cart
                        #{user_cart.id}"
      user_cart.merge_with!(guest_cart)
      # Reset current_cart to get updated cart
      @current_cart = nil
    end

    session.delete(:cart_session_id)
  end
end
