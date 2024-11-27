class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      @pagy, @feed_items = pagy current_user.feed.order(created_at: :desc), items: Settings.default.microposts_per_page
    end
  end

  def help;  end

  def about; end

  def contact; end
end
