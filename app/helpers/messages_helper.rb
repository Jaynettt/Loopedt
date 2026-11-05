
module MessagesHelper
  def unread_message_count(user)
    return 0 unless user

    Conversation
      .where("conversations.buyer_id = :id OR conversations.seller_id = :id", id: user.id)
      .joins(:messages)
      .merge(Message.approved.unread)
      .where.not(messages: { sender_id: user.id })
      .count("messages.id")
  end
end
