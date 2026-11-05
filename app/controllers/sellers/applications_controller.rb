
module Sellers
  class ApplicationsController < BaseController
    before_action :set_draft_application, only: [:kyc, :update_kyc, :submit]

    def new
      @seller_application = current_user.seller_application

      if @seller_application&.status == "approved"
        redirect_to seller_dashboard_path
      elsif @seller_application&.status == "draft"
        redirect_to seller_onboarding_kyc_path
      elsif @seller_application
        redirect_to seller_application_path
      else
        @seller_application = current_user.build_seller_application
      end
    end

    # Step 1: Save shop details as a draft
    def create
      existing_application = current_user.seller_application

      if existing_application
        if existing_application.status == "draft"
          redirect_to seller_onboarding_kyc_path
        else
          redirect_to seller_application_path,
                      alert: "You already have a seller application."
        end
        return
      end

      @seller_application = current_user.build_seller_application(
        seller_application_params.merge(status: "draft")
      )

      if @seller_application.save
        redirect_to seller_onboarding_kyc_path,
                    notice: "Shop details saved. Now complete your identity verification."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # Step 2: Display the KYC form
    def kyc
    end

    # Save KYC details and uploaded documents
    def update_kyc
      if @seller_application.update(kyc_params)
        redirect_to seller_onboarding_kyc_path,
                    notice: "Your verification details have been saved."
      else
        render :kyc, status: :unprocessable_entity
      end
    end

    # Final submission
    def submit
      unless kyc_complete?
        render :kyc, status: :unprocessable_entity
        return
      end

      if @seller_application.update(
        status: "pending",
        kyc_submitted_at: Time.current
      )
        redirect_to seller_application_path,
                    notice: "Your seller application has been submitted for review."
      else
        render :kyc, status: :unprocessable_entity
      end
    end

    # Application tracking
    def show
      @application = current_user.seller_application

      unless @application
        redirect_to seller_onboarding_path,
                    alert: "Please complete your seller application first."
        return
      end

      if @application.status == "draft"
        redirect_to seller_onboarding_kyc_path
      end
    end

    private

    def set_draft_application
      @seller_application = current_user.seller_application

      return if @seller_application&.status == "draft"

      redirect_to seller_onboarding_path,
                  alert: "Please complete your shop application first."
    end

    def seller_application_params
      params.require(:seller_application).permit(
        :shop_name,
        :description,
        :location
      )
    end

    def kyc_params
      params.require(:seller_application).permit(
        :legal_full_name,
        :date_of_birth,
        :phone_number,
        :residential_address,
        :city,
        :state,
        :lga,
        :postal_code,
        :id_type,
        :id_number,
        :identity_document,
        :proof_of_address
      )
    end

    def kyc_complete?
      required_fields = [
        :legal_full_name,
        :date_of_birth,
        :phone_number,
        :residential_address,
        :city,
        :state,
        :lga,
        :id_type,
        :id_number
      ]

      required_fields.each do |field|
        if @seller_application.public_send(field).blank?
          @seller_application.errors.add(field, "is required")
        end
      end

      unless @seller_application.identity_document.attached?
        @seller_application.errors.add(
          :identity_document,
          "must be uploaded"
        )
      end

      unless @seller_application.proof_of_address.attached?
        @seller_application.errors.add(
          :proof_of_address,
          "must be uploaded"
        )
      end

      @seller_application.errors.empty?
    end
  end
end
