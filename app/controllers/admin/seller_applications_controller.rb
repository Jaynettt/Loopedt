
module Admin
  class SellerApplicationsController < BaseController
    before_action :set_application,
                  only: [
                    :show,
                    :update,
                    :identity_document,
                    :proof_of_address
                  ]

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

      unless @application.status == "pending"
        redirect_to admin_seller_application_path(@application),
                    alert: "This application is not awaiting review."
        return
      end

      if new_status == "approved" && !kyc_ready?
        redirect_to admin_seller_application_path(@application),
                    alert: "This application cannot be approved until KYC and both documents are submitted."
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

    # Secure identity document download
    def identity_document
      download_private_document(@application.identity_document)
    end

    # Secure proof of address download
    def proof_of_address
      download_private_document(@application.proof_of_address)
    end

    def identity_document_preview
      document = @application.identity_document

      unless document.attached?
        redirect_to admin_seller_application_path(@application),
                    alert: "No identity document has been uploaded."
        return
      end

      unless document.content_type.in?(%w[image/jpeg image/png image/webp])
        redirect_to admin_seller_application_path(@application),
                    alert: "This document cannot be previewed as an image."
        return
      end

      response.headers["Cache-Control"] = "private, no-store"
      response.headers["X-Content-Type-Options"] = "nosniff"

      send_data document.download,
                type: document.content_type,
                disposition: "inline",
                filename: document.filename.to_s
    end
    
    private

    def set_application
      @application = SellerApplication.find(params[:id])
    end

    def kyc_ready?
      @application.kyc_submitted_at.present? &&
        @application.identity_document.attached? &&
        @application.proof_of_address.attached?
    end

    def download_private_document(document)
      unless document.attached?
        redirect_to admin_seller_application_path(@application),
                    alert: "This document has not been uploaded."
        return
      end

      response.headers["Cache-Control"] = "private, no-store"

      send_data document.download,
                filename: document.filename.to_s,
                type: "application/octet-stream",
                disposition: "attachment"
    end
  end
end
