
module Web
  class ConversationsController < BaseController
    before_action :set_conversation, only: [:show, :create_message]
    before_action :authorize_participant, only: [:show, :create_message]

    def index
      @current_user = current_user

      @conversations = Conversation
        .where(buyer: @current_user)
        .or(Conversation.where(seller: @current_user))
        .includes(:listing, :buyer, :seller)
        .order(updated_at: :desc)

      conversation_ids = @conversations.map(&:id)

      @unread_counts = Message
        .where(
          conversation_id: conversation_ids,
          moderation_status: "approved",
          read_at: nil
        )
        .where.not(sender_id: @current_user.id)
        .group(:conversation_id)
        .count
    end

    def show
      @current_user = current_user

      # Mark incoming approved messages as read.
      @conversation.messages
        .where(moderation_status: "approved", read_at: nil)
        .where.not(sender_id: @current_user.id)
        .update_all(read_at: Time.current)

      @messages = @conversation.messages
        .where(moderation_status: "approved")
        .includes(:sender)
        .order(:created_at)

      @message = @conversation.messages.build
    end

    def create_message
      body = params[:body].to_s.strip

      @message = @conversation.messages.build(
        sender: current_user,
        body: body,
        moderation_status: "pending"
      )

      # Check for phone numbers, emails, social handles and links.
      filter_result = MessageFilter.new(body).call

      if filter_result.blocked
        redirect_to inbox_conversation_path(@conversation),
                    alert: "Your message contains contact information. Please keep communication on Loopedt."
        return
      end

      # Run the existing content moderation system.
      moderation_status = MessageModerator.moderate(body).to_s

      @message.moderation_status = moderation_status

      if @message.save && moderation_status == "approved"
        redirect_to inbox_conversation_path(@conversation),
                    notice: "Message sent."

      elsif moderation_status == "blocked"
        redirect_to inbox_conversation_path(@conversation),
                    alert: "Your message was blocked by our moderation system."

      else
        redirect_to inbox_conversation_path(@conversation),
                    alert: @message.errors.full_messages.to_sentence.presence ||
                           "Message could not be sent."
      end
    end

    def create_for_listing
      listing = Listing.find(params[:listing_id])

      if listing.user_id == current_user.id
        redirect_to listings_path, alert: "You cannot message yourself."
        return
      end

      conversation = Conversation.find_or_create_by!(
        listing: listing,
        buyer: current_user,
        seller: listing.user,
        status: "open"
      )

      redirect_to inbox_conversation_path(conversation)
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
  end
end
