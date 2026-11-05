module Web
  class OrdersController < BaseController
    def index
      @orders = Order
        .includes(:listing, :buyer, :seller)
        .where("buyer_id = :user_id OR seller_id = :user_id",
               user_id: current_user.id)
        .order(created_at: :desc)
    end

    def show
      @order = Order
        .includes(:listing, :buyer, :seller)
        .where("buyer_id = :user_id OR seller_id = :user_id",
               user_id: current_user.id)
        .find(params[:id])
    end

    def ready_for_dispatch
      @order = Order.where(seller_id: current_user.id).find(params[:id])

      ready = false

      @order.with_lock do
        if @order.status == "paid" &&
           @order.delivery_status == "pending"

          @order.update!(delivery_status: "ready_for_dispatch")
          ready = true
        end
      end

      if ready
        redirect_to order_path(@order),
                    notice: "Order marked as ready for dispatch."
      else
        redirect_to order_path(@order),
                    alert: "This order is not eligible for dispatch."
      end
    end
  end
end
