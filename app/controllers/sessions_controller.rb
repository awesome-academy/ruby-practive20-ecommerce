class SessionsController < ApplicationController
  # GET /login
  def new; end

  # POST /login
  def create # rubocop:disable Metrics/AbcSize
    user = User.find_by(email: params.dig(:session, :email)&.downcase)
    if user&.authenticate(params.dig(:session, :password))
      # Store cart session ID before resetting session
      cart_session_id = session[:cart_session_id]

      reset_session
      log_in user

      # Restore cart session ID for cart merging
      session[:cart_session_id] = cart_session_id if cart_session_id.present?

      # Explicitly trigger cart merge after login
      sync_guest_cart_with_user_cart

      remember_user_if_needed(user)
      flash[:success] = t(".login_success")
      redirect_to user
    else
      flash.now[:danger] = t(".login_failed")
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    log_out if logged_in?
    flash[:success] = t(".logout_success")
    redirect_to root_path
  end

  private

  def remember_user_if_needed user
    if params.dig(:session, :remember_me) == Settings.session.remember_me_value
      remember user
    else
      # Only clear cookies, don't clear remember_digest because it's
      # needed for session authentication
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end
  end
end
