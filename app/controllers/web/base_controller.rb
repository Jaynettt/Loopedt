
module Web
  class BaseController < ActionController::Base
    before_action :authenticate_web_user!

    private

    def authenticate_web_user!
      unless session[:user_id]
        redirect_to "/login", alert: "Please log in to continue."
        return
      end

      @current_user = User.find_by(id: session[:user_id])

      unless @current_user
        reset_session
        redirect_to "/login", alert: "Please log in to continue."
      end
    end

    def current_user
      @current_user
    end
  end
end
