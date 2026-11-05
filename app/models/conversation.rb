
class Conversation < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :status, presence: true

  validate :buyer_and_seller_must_be_different
  validate :seller_must_own_listing

  validates :negotiation_status,
          inclusion: {
            in: %w[not_requested requested active agreed declined]
          }

  has_many :negotiation_offers, dependent: :destroy

  def latest_negotiation_offer
    negotiation_offers.order(created_at: :desc).first
  end

  private

  def buyer_and_seller_must_be_different
    if buyer_id.present? && buyer_id == seller_id
      errors.add(:buyer, "cannot message themselves")
    end
  end

  def seller_must_own_listing
    if listing && seller_id.present? && listing.user_id != seller_id
      errors.add(:seller, "must own the listing")
    end
  end
end
