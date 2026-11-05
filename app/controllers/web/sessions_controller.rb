
module Web
  class SessionsController < ActionController::Base
    def new
    end

      def create
      user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          session[:user_id] = user.id

          if user.admin?
            redirect_to admin_root_path, notice: "Welcome to the admin dashboard!"
          else
            redirect_to "/inbox", notice: "Welcome back to Loopedt!"
          end
        else
          flash.now[:alert] = "Invalid email or password."
          render :new, status: :unprocessable_entity
        end
      end
      
    def destroy
      reset_session
      redirect_to "/login", notice: "You have been logged out."
    end
  end
end
