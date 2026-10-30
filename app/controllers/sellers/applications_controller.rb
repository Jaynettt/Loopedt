
module Sellers
  class ApplicationsController < BaseController
    def new
      @seller_application = current_user.seller_application

      if @seller_application&.status == "approved"
        redirect_to seller_dashboard_path
      elsif @seller_application
        redirect_to seller_application_path
      else
        @seller_application = current_user.build_seller_application
      end
    end

    def create
      if current_user.seller_application
        redirect_to seller_application_path,
                    alert: "You have already submitted a seller application."
        return
      end

      @seller_application = current_user.build_seller_application(
        seller_application_params
      )

      if @seller_application.save
        redirect_to seller_application_path,
                    notice: "Your seller application has been submitted!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @application = current_user.seller_application

      unless @application
        redirect_to seller_onboarding_path,
                    alert: "Please submit a seller application first."
      end
    end

    private

    def seller_application_params
      params.require(:seller_application).permit(
        :shop_name,
        :description,
        :location
      )
    end
  end
end
