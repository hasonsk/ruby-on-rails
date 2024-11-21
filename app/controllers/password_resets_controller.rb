class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration,
                                        only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_reset.email_sent_with_pw_reset_instructions"
      redirect_to root_url
    else
      flash.now[:danger] = t "password_reset.email_address_not_found"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("password_reset.cant_be_empty")
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t "password_reset.pw_has_been_reset"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "password_reset.user_not_found"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    unless @user && @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "password_reset.pw_reset_has_expired"
      redirect_to new_password_reset_url
    end
  end
end
