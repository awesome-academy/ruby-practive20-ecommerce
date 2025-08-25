class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Backend
  before_action :set_locale

  private

  def set_locale
    if Settings.i18n.available_locales.include?(params[:locale])
      locale = params[:locale]
    end
    I18n.locale = locale || Settings.i18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def require_login
    return if logged_in?

    flash[:danger] = t("users.edit.login_required")
    redirect_to login_path
  end

  def correct_user
    return if @user == current_user

    flash[:danger] = t("users.edit.not_authorized")
    redirect_to root_path
  end
end
