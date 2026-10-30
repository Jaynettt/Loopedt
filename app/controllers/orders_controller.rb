class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update]

  def index
    if params[:buyer_id].present?
      @orders = Order.where(buyer_id: params[:buyer_id])
    elsif params[:seller_id].present?
      @orders = Order.where(seller_id: params[:seller_id])
    else
      @orders = Order.all
    end

    @orders = @orders.includes(:listing, :buyer, :seller)
                     .order(created_at: :desc)

    render :index
  end

  def show
    render :show
  end

  def create
    listing = Listing.find(params[:listing_id])

    buyer = User.find(params[:buyer_id])
    seller = listing.user

    @order = Order.new(
      listing: listing,
      buyer: buyer,
      seller: seller,
      amount: listing.price,
      status: "pending"
    )

    if @order.save
      render :show, status: :created
    else
      render json: {
        error: "Unable to create order",
        messages: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render :show
    else
      render json: {
        error: "Unable to update order",
        messages: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.includes(:listing, :buyer, :seller).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
