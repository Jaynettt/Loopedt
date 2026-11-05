module Admin
  class DashboardController < BaseController
    def index
      @total_applications = SellerApplication.count
      @pending_applications = SellerApplication.where(status: "pending").count
      @approved_applications = SellerApplication.where(status: "approved").count
      @rejected_applications = SellerApplication.where(status: "rejected").count

      @recent_applications = SellerApplication.includes(:user)
                                               .order(created_at: :desc)
                                               .limit(5)
    end
  end
end
