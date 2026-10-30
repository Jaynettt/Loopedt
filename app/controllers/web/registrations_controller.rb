
module Web
  class RegistrationsController < ActionController::Base
    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        wants_to_sell = params[:intent] == "seller"

        reset_session
        session[:user_id] = @user.id

        if wants_to_sell
          redirect_to "/seller-onboarding",
                      notice: "Account created! Set up your seller profile."
        else
          redirect_to listings_path,
                      notice: "Welcome to Loopedt! Your buyer account is ready."
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :username,
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation
      )
    end
  end
end
