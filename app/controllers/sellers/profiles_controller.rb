module Sellers
  class ProfilesController < Web::PublicController
    def show
      @seller = User
        .joins(:seller_application)
        .includes(:seller_application)
        .find_by!(
          id: params[:id],
          seller_applications: { status: "approved" }
        )

      @seller_application = @seller.seller_application

      @listings = @seller.listings
        .includes(:category)
        .with_attached_images
        .where(status: "available")
        .order(created_at: :desc)

      @completed_sales = Order.where(
        seller_id: @seller.id,
        status: "completed"
      ).count
    end
  end
end
