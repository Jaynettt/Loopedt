module Admin
  class SellerApplicationsController < BaseController
    before_action :set_application, only: [:show, :update]

    def index
      @applications = SellerApplication.includes(:user)
                                        .order(
                                          Arel.sql(
                                            "CASE
                                              WHEN status = 'pending' THEN 0
                                              WHEN status = 'approved' THEN 1
                                              ELSE 2
                                            END"
                                          ),
                                          created_at: :desc
                                        )
    end

    def show
    end

    def update
      new_status = params[:status]

      unless ["approved", "rejected"].include?(new_status)
        redirect_to admin_seller_application_path(@application),
                    alert: "Invalid application decision."
        return
      end

      if @application.update(status: new_status)
        redirect_to admin_seller_application_path(@application),
                    notice: "Application #{new_status} successfully."
      else
        redirect_to admin_seller_application_path(@application),
                    alert: "Unable to update this application."
      end
    end

    private

    def set_application
      @application = SellerApplication.find(params[:id])
    end
  end
end
