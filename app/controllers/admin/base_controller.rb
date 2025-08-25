class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  private

  def authenticate_admin!
    return if current_user&.admin?

    flash[:danger] = t("admin.access_denied")
    redirect_to login_path
  end
end
