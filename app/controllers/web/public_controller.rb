
module Web
  class PublicController < ActionController::Base
    layout "application"

    before_action :set_navigation_data

    private

    def set_navigation_data
      @nav_user = User.find_by(id: session[:user_id]) if session[:user_id]

      return unless @nav_user

      @cart_count = @nav_user.cart_items.sum(:quantity)
    end
  end
end
