
class CartItemsController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    @cart_items = current_user.cart_items.includes(listing: :user)
  end

  def create
    listing = Listing.find(params[:listing_id])

    if listing.user_id == current_user.id
      respond_to do |format|
        format.html do
          redirect_to root_path, alert: "You cannot add your own listing to your cart."
        end

        format.json do
          render json: { error: "You cannot add your own listing to your cart." },
                status: :unprocessable_entity
        end
      end
      return
    end

    cart_item = current_user.cart_items.find_or_initialize_by(listing: listing)

    if cart_item.new_record?
      cart_item.quantity = 1
    else
      cart_item.quantity += 1
    end

    if cart_item.save
      cart_count = current_user.cart_items.sum(:quantity)

      respond_to do |format|
        format.html do
          redirect_to cart_items_path, notice: "Item added to your cart."
        end

        format.json do
          render json: {
            message: "Item added to your cart.",
            cart_count: cart_count
          }, status: :created
        end
      end
    else
      respond_to do |format|
        format.html do
          redirect_to root_path, alert: cart_item.errors.full_messages.to_sentence
        end

        format.json do
          render json: { error: cart_item.errors.full_messages.to_sentence },
                status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @cart_item.update(quantity: params[:quantity])
      redirect_to cart_items_path, notice: "Cart updated."
    else
      redirect_to cart_items_path, alert: @cart_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @cart_item.destroy
    redirect_to cart_items_path, notice: "Item removed from your cart."
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    unless current_user
      redirect_to "/login", alert: "Please log in to continue."
    end
  end

  def set_cart_item
    @cart_item = current_user.cart_items.find(params[:id])
  end
end
