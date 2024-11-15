class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session

        if params[:session][:remember_me] == "1"
          remember(user)
        else
          forget(user)
        end

        log_in user
        redirect_to forwarding_url || user

      else
        flash[:warning] = t "user.account_not_activated"
        redirect_to root_url
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
