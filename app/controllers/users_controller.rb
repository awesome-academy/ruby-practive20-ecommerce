class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update)
  before_action :require_login, only: %i(edit update)
  before_action :correct_user, only: %i(edit update)

  # GET /users/:id
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
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

  # GET /users/:id/edit
  def edit; end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = t(".update_success")
      redirect_to @user
    else
      flash.now[:error] = t(".update_failed")
      render :edit, status: :unprocessable_entity
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
