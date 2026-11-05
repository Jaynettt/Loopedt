
class CartItemsController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    @cart_items = current_user.cart_items.includes(listing: :user)
  end

  def create
    listing = Listing.find(params[:listing_id])

    if listing.user_id == current_user.id
      redirect_to root_path,
                  alert: "You cannot add your own listing to your cart."
      return
    end

    Listing.transaction do
      listing.lock!

      cart_item = current_user.cart_items.find_or_initialize_by(
        listing: listing
      )

      new_quantity = cart_item.quantity.to_i + 1

      unless listing.available_for_purchase? &&
             new_quantity <= listing.available_quantity
        raise ActiveRecord::RecordInvalid.new(cart_item.tap do |item|
          item.errors.add(
            :quantity,
            "cannot exceed the #{listing.available_quantity} units currently available"
          )
        end)
      end

      cart_item.quantity = new_quantity
      cart_item.save!
    end

    respond_to do |format|
      format.html do
        redirect_to cart_items_path, notice: "Item added to your cart."
      end

      format.json do
        render json: {
          message: "Item added to your cart.",
          cart_count: current_user.cart_items.sum(:quantity)
        }, status: :created
      end
    end

  rescue ActiveRecord::RecordInvalid => e
    message = e.record.errors.full_messages.to_sentence

    respond_to do |format|
      format.html { redirect_to root_path, alert: message }
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end

  def update
    quantity = params[:quantity].to_i

    if quantity < 1
      render json: { error: "Quantity must be at least 1." },
             status: :unprocessable_entity
      return
    end

    listing = @cart_item.listing

    Listing.transaction do
      listing.lock!

      unless listing.available_for_purchase? &&
             quantity <= listing.available_quantity
        raise ActiveRecord::RecordInvalid.new(@cart_item.tap do |item|
          item.errors.add(
            :quantity,
            "cannot exceed the #{listing.available_quantity} units currently available"
          )
        end)
      end

      @cart_item.update!(quantity: quantity)
    end

    cart_total = current_user.cart_items.includes(:listing).sum do |item|
      item.effective_unit_price * item.quantity
    end

    render json: {
      message: "Cart updated.",
      quantity: @cart_item.quantity,
      item_total: @cart_item.effective_unit_price * @cart_item.quantity,
      cart_total: cart_total,
      cart_count: current_user.cart_items.sum(:quantity)
    }

  rescue ActiveRecord::RecordInvalid => e
    render json: {
      error: e.record.errors.full_messages.to_sentence
    }, status: :unprocessable_entity
  end

  def destroy
    @cart_item.destroy

    respond_to do |format|
      format.html do
        redirect_to cart_items_path, notice: "Item removed from your cart."
      end

      format.json do
        render json: {
          message: "Item removed from your cart.",
          cart_total: current_user.cart_items.includes(:listing).sum do |item|
            item.effective_unit_price * item.quantity
          end,
          cart_count: current_user.cart_items.sum(:quantity)
        }
      end
    end
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
