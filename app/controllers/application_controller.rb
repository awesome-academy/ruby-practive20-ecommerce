class ApplicationController < ActionController::Base
  include SessionsHelper
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
end
