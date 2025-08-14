class UsersController < ApplicationController
  before_action :load_user, only: [:show]

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in @user
      flash[:success] = t(".user_created_successfully")
      redirect_to @user
    else
      flash.now[:error] = t(".user_creation_failed")
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit User::USER_PERMIT
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_path
  end
end
