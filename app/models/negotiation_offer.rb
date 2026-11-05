class NegotiationOffer < ApplicationRecord
  belongs_to :conversation
  belongs_to :proposer, class_name: "User"

  STATUSES = %w[pending accepted rejected countered].freeze

  validates :amount,
            numericality: { greater_than: 0 }

  validates :status, inclusion: { in: STATUSES }

  validate :proposer_must_be_participant

  private

  def proposer_must_be_participant
    return unless conversation && proposer

    unless [conversation.buyer_id, conversation.seller_id].include?(proposer.id)
      errors.add(:proposer, "must belong to this conversation")
    end
  end
end
