module SessionsHelper
  # Logs in the given user
  def log_in user
    user.generate_session_token
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  def current_user
    @current_user ||= current_user_from_session ||
                      current_user_from_remember_token
  end

  def logged_in?
    current_user.present?
  end

  # Logs out the current user
  def log_out
    user = current_user
    if user
      user.forget_session
      forget(user)
    end
    reset_session
    @current_user = nil
  end

  private

  def current_user_from_session
    return unless (user_id = session[:user_id]) &&
                  (session_token = session[:session_token])

    user = User.find_by(id: user_id)
    user if user&.authenticated?(session_token)
  end

  def current_user_from_remember_token
    return unless (user_id = cookies.signed[:user_id])

    user = User.find_by(id: user_id)
    return unless user&.authenticated?(cookies[:remember_token])

    log_in user
    user
  end

  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end
