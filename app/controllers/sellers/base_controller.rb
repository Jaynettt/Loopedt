
module Sellers
  class BaseController < ActionController::Base
    before_action :require_seller_login!

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def require_seller_login!
      unless current_user
        redirect_to "/login", alert: "Please log in first."
      end
    end

    def require_approved_seller!
      application = current_user&.seller_application

      unless application&.status == "approved"
        redirect_to seller_onboarding_path,
                    alert: "Your seller application is not yet approved."
      end
    end
  end
end
