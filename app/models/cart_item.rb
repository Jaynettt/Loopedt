class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :listing

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }

  validate :cannot_add_own_listing

  private

  def cannot_add_own_listing
    if user_id.present? && listing&.user_id == user_id
      errors.add(:listing, "cannot be your own listing")
    end
  end
end
