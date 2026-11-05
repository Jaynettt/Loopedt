module Admin
  class BaseController < ActionController::Base
    before_action :require_admin!

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def require_admin!
      unless current_user
        redirect_to "/login", alert: "Please log in first."
        return
      end

      unless current_user.admin?
        redirect_to "/", alert: "You are not authorized to access this page."
      end
    end
  end
end
