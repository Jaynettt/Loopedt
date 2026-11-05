class NotificationBroadcaster
  def self.broadcast_unread_count(user)
    conversation_ids = Conversation
      .where("buyer_id = :id OR seller_id = :id", id: user.id)
      .select(:id)

    unread_count = Message
      .where(conversation_id: conversation_ids)
      .where(moderation_status: "approved", read_at: nil)
      .where.not(sender_id: user.id)
      .count

    ActionCable.server.broadcast(
      "notifications_user_#{user.id}",
      { unread_count: unread_count }
    )
  end
end
