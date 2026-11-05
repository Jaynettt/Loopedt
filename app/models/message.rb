class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 2000 }

  validates :moderation_status,
            inclusion: {
              in: %w[pending approved blocked flagged]
            }

  validates :message_type,
            inclusion: {
              in: %w[chat system]
            }

  validate :sender_must_belong_to_conversation
  validate :message_must_not_contain_contact_details

  scope :unread, -> { where(read_at: nil) }
  scope :approved, -> { where(moderation_status: "approved") }

  private

  def sender_must_belong_to_conversation
    return unless conversation && sender_id.present?

    unless [conversation.buyer_id, conversation.seller_id].include?(sender_id)
      errors.add(:sender, "must be part of this conversation")
    end
  end

  def message_must_not_contain_contact_details
    result = MessageFilter.new(body).call

    if result.blocked
      errors.add(
        :body,
        "contains contact information. Please keep communication on Loopedt."
      )
    end
  end
end
