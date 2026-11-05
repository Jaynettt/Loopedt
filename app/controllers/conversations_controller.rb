

  class ConversationsController < ActionController::Base
    before_action :set_conversation, only: [:show]

    def index
      @conversations = Conversation
        .where(buyer: current_user)
        .or(Conversation.where(seller: current_user))
        .includes(:listing, :buyer, :seller)
        .order(updated_at: :desc)
    end

    def show
      unless [@conversation.buyer_id, @conversation.seller_id].include?(current_user.id)
        redirect_to "/inbox", alert: "You cannot access this conversation."
        return
      end

      @messages = @conversation.messages
        .where(moderation_status: "approved")
        .includes(:sender)
        .order(:created_at)

      @message = @conversation.messages.build
    end

    private

    def set_conversation
      @conversation = Conversation.find(params[:id])
    end
  end

