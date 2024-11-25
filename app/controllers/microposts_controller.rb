class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach params[:micropost][:image]

    if @micropost.save
      flash[:success] = t "home.micropost_created"
      redirect_to root_url
    else
      @pagy, @feed_items = pagy current_user.feed.order(created_at: :desc), items: Settings.default.microposts_per_page
      render "static_pages/home", status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "home.micropost_deleted"
    if request.referer.nil? || request.referer == microposts_url
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referer, status: :see_other
    end
  end

  private
  def micropost_params
    params.require(:micropost).permit(Micropost::MICROPOST_PERMITTED_ATTRIBUTES)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost.present?
    flash[:danger] = t "home.unauthorized_action"
    redirect_to root_url, status: :see_other
  end
end
