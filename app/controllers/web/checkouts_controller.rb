
module Web
  class CheckoutsController < BaseController
    skip_before_action :authenticate_web_user!, only: :callback

    def show
      @checkout = current_user.checkouts.find(params[:id])
    end

    def create
      cart_items = current_user.cart_items.includes(:listing)

      result = CheckoutFeeCalculator.new(cart_items).calculate

      ActiveRecord::Base.transaction do
        @checkout = current_user.checkouts.create!(
          subtotal: result[:subtotal],
          service_fee: result[:service_fee],
          payment_fee: result[:payment_fee],
          total_amount: result[:total_amount],
          status: "pending"
        )

        cart_items.each do |item|
          listing = item.listing

          @checkout.orders.create!(
            listing: listing,
            buyer: current_user,
            seller: listing.user,
            amount: listing.price * item.quantity,
            status: "pending"
          )
        end
      end

      redirect_to checkout_path(@checkout),
                  notice: "Your checkout has been created."

    rescue ArgumentError => e
      redirect_to cart_items_path, alert: e.message

    rescue ActiveRecord::RecordInvalid => e
      redirect_to cart_items_path,
                  alert: e.record.errors.full_messages.to_sentence
    end

    def pay
      checkout = current_user.checkouts.find(params[:id])

      unless checkout.status == "pending"
        redirect_to checkout_path(checkout),
                    alert: "This checkout is no longer awaiting payment."
        return
      end

      response = PaystackService.new.initialize_transaction(
        checkout: checkout,
        email: current_user.email,
        callback_url: "#{request.base_url}#{paystack_callback_path}"
      )

      redirect_to response.fetch("authorization_url"),
                  allow_other_host: true

    rescue PaystackService::Error => e
      redirect_to checkout_path(checkout),
                  alert: "Unable to start payment: #{e.message}"
    end

    def callback
      reference = params[:reference].presence || params[:trxref]

      raise PaystackService::Error, "Missing payment reference" if reference.blank?

      checkout = Checkout.find_by!(payment_reference: reference)

      payment = PaystackService.new.verify_transaction(
        reference: reference
      )

      expected_amount =
        (BigDecimal(checkout.total_amount.to_s) * 100).round.to_i

      unless payment["reference"] == reference &&
             payment["status"] == "success" &&
             payment["amount"].to_i == expected_amount &&
             payment["currency"] == "NGN"
        redirect_after_payment(checkout, "Payment could not be confirmed.")
        return
      end

      checkout.with_lock do
        unless checkout.status == "paid"
          checkout.update!(status: "paid")

          checkout.orders.update_all(
            status: "paid",
            updated_at: Time.current
          )

          listing_ids = checkout.orders.pluck(:listing_id)

          CartItem.where(
            user_id: checkout.buyer_id,
            listing_id: listing_ids
          ).destroy_all
        end
      end

      redirect_after_payment(
        checkout,
        "Payment successful! Your order has been confirmed.",
        success: true
      )

    rescue PaystackService::Error => e
      redirect_after_payment(checkout, e.message) if checkout
      redirect_to "/login", alert: e.message unless checkout
    rescue ActiveRecord::RecordNotFound
      redirect_to "/login", alert: "We couldn't find that checkout."
    end

    private

    def redirect_after_payment(checkout, message, success: false)
      if session[:user_id].to_i == checkout.buyer_id
        redirect_to checkout_path(checkout),
                    (success ? { notice: message } : { alert: message })
      else
        redirect_to "/login", notice: message
      end
    end
  end
end
