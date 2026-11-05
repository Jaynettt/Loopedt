
module Web
  class NegotiationsController < BaseController
    before_action :set_conversation
    before_action :authorize_participant

    def request_negotiation
      unless current_user.id == @conversation.buyer_id
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Only the buyer can request negotiation."
      end

      unless @conversation.negotiation_status == "not_requested"
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "A negotiation has already been requested."
      end

      ActiveRecord::Base.transaction do
        @conversation.update!(negotiation_status: "requested")

        @conversation.messages.create!(
          sender: current_user,
          body: "A negotiation request has been submitted for this listing.",
          message_type: "system",
          moderation_status: "approved"
        )
      end

      NotificationBroadcaster.broadcast_unread_count(
        User.find(@conversation.seller_id)
      )

      redirect_to inbox_conversation_path(@conversation),
                  notice: "Negotiation request sent."
    end

    def respond_to_request
      unless current_user.id == @conversation.seller_id
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Only the seller can respond."
      end

      unless @conversation.negotiation_status == "requested"
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "No pending negotiation request."
      end

      case params[:decision]
      when "accept"
        if @conversation.listing.minimum_negotiable_price.blank?
          return redirect_to inbox_conversation_path(@conversation),
                             alert: "Set your minimum negotiable price first."
        end

        @conversation.update!(negotiation_status: "active")

        redirect_to inbox_conversation_path(@conversation),
                    notice: "Negotiation accepted."

      when "decline"
        @conversation.update!(negotiation_status: "declined")

        redirect_to inbox_conversation_path(@conversation),
                    notice: "Negotiation declined."

      else
        redirect_to inbox_conversation_path(@conversation),
                    alert: "Invalid response."
      end
    end

    def create_offer
      unless current_user.id == @conversation.buyer_id
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Only the buyer can submit an opening offer."
      end

      unless @conversation.negotiation_status == "active"
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Negotiation is not active."
      end

      amount = parse_amount(params[:amount])
      return unless amount

      latest = @conversation.latest_negotiation_offer

      if latest&.status == "pending"
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Respond to the current offer first."
      end

      minimum = @conversation.listing.minimum_negotiable_price

      if minimum.blank? || amount < minimum ||
         amount >= @conversation.listing.price
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "Your offer is outside the acceptable range."
      end

      submit_offer(amount)
    end

    def respond_to_offer
      offer = @conversation.negotiation_offers.find(params[:offer_id])

      unless offer.status == "pending" &&
             offer.proposer_id != current_user.id
        return redirect_to inbox_conversation_path(@conversation),
                           alert: "You cannot respond to this offer."
      end

      case params[:decision]
      when "accept"
        if current_user.id == @conversation.seller_id &&
           offer.amount < @conversation.listing.minimum_negotiable_price
          return redirect_to inbox_conversation_path(@conversation),
                             alert: "This offer cannot be accepted."
        end

        ActiveRecord::Base.transaction do
          offer.update!(status: "accepted")

          @conversation.update!(
            negotiation_status: "agreed",
            agreed_price: offer.amount
          )

          cart_item = CartItem.find_or_initialize_by(
            user_id: @conversation.buyer_id,
            listing_id: @conversation.listing_id
          )

          cart_item.assign_attributes(
            unit_price: offer.amount,
            quantity: 1
          )

          cart_item.save!
        end

        redirect_to inbox_conversation_path(@conversation),
                    notice: "Offer accepted. The agreed price is saved and the item has been added to your cart."

      when "reject"
        ActiveRecord::Base.transaction do
          offer.update!(status: "rejected")
          @conversation.update!(negotiation_status: "active")
        end

        redirect_to inbox_conversation_path(@conversation),
                    notice: "Offer rejected."

      when "counter"
        amount = parse_amount(params[:amount])
        return unless amount

        minimum = @conversation.listing.minimum_negotiable_price

        if current_user.id == @conversation.seller_id
          if minimum.blank? || amount < minimum ||
             amount >= @conversation.listing.price
            return redirect_to inbox_conversation_path(@conversation),
                               alert: "Your counteroffer must be within your acceptable range."
          end
        elsif amount >= @conversation.listing.price
          return redirect_to inbox_conversation_path(@conversation),
                             alert: "Your counteroffer must be below the advertised price."
        end

        ActiveRecord::Base.transaction do
          offer.update!(status: "countered")

          @conversation.negotiation_offers.create!(
            proposer: current_user,
            amount: amount,
            status: "pending"
          )
        end

        redirect_to inbox_conversation_path(@conversation),
                    notice: "Counteroffer submitted."

      else
        redirect_to inbox_conversation_path(@conversation),
                    alert: "Invalid response."
      end
    end

    private

    def set_conversation
      @conversation = Conversation.find(params[:id])
    end

    def authorize_participant
      return if [
        @conversation.buyer_id,
        @conversation.seller_id
      ].include?(current_user.id)

      redirect_to inbox_path,
                  alert: "You cannot access this conversation."
    end

    def parse_amount(value)
      amount = BigDecimal(value.to_s)

      unless amount.positive?
        redirect_to inbox_conversation_path(@conversation),
                    alert: "Enter a valid amount."
        return nil
      end

      amount
    rescue ArgumentError, TypeError
      redirect_to inbox_conversation_path(@conversation),
                  alert: "Enter a valid amount."
      nil
    end

    def submit_offer(amount)
      @conversation.negotiation_offers.create!(
        proposer: current_user,
        amount: amount,
        status: "pending"
      )

      redirect_to inbox_conversation_path(@conversation),
                  notice: "Your offer has been submitted."
    end
  end
end
