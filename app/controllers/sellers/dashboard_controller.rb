
module Sellers
  class DashboardController < BaseController
    before_action :require_approved_seller!

    def index
      @seller = current_user
      @seller_application = @seller.seller_application

      @listings = @seller.listings.order(created_at: :desc)

      @total_listings = @listings.count
      @active_listings = @listings.where(status: "available").count
      @sold_listings = @listings.where(status: "sold").count

      @recent_orders = Order.where(seller_id: @seller.id)
                            .includes(:listing, :buyer)
                            .order(created_at: :desc)
                            .limit(5)
    end
  end
end
