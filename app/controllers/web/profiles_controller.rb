
module Web
  class ProfilesController < PublicController
    before_action :require_login!
    before_action :set_profile_data

    def show
    end

    def edit
    end

    def update
      ActiveRecord::Base.transaction do
        current_user.update!(user_params)

        if @seller_application.present? && params[:seller_application].present?
          @seller_application.update!(seller_params)
        end
      end

      redirect_to my_profile_path, notice: "Your profile has been updated."
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def require_login!
      unless current_user
        redirect_to "/login", alert: "Please log in to view your profile."
      end
    end

    def set_profile_data
      return unless current_user

      @profile_user = current_user
      @seller_application = current_user.seller_application
    end

    def user_params
      params.require(:user).permit(
        :username,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :bio
      )
    end

    def seller_params
      params.require(:seller_application).permit(
        :shop_name,
        :description,
        :location
      )
    end
  end
end
