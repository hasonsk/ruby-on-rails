class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update index)
  before_action :set_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.where(activated: true), items: Settings.default.users_per_page)
  end

  def show
    @user = User.find params[:id]
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = t "user.please_check_your_mail"
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "user.profile_updated"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t "user.user_deleted"
    redirect_to users_url, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(User::PERMITTED_ATTRIBUTES)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "user.please_login"
    redirect_to login_url, status: :see_other
  end

  def correct_user
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user&.admin?
  end
end
