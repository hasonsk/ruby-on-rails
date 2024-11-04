class ApplicationController < ActionController::Base
  rescue_from Exception, with: :render_not_found

  private
  def render_not_found _exception
    render plain: "404 Not Found", status: :not_found
  end

  include SessionsHelper
end
