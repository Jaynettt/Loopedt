
class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :listing

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }

  validate :cannot_add_own_listing
  validate :quantity_cannot_exceed_available_stock

  def effective_unit_price
    unit_price || listing.price
  end

  private

  def cannot_add_own_listing
    if user_id.present? && listing&.user_id == user_id
      errors.add(:listing, "cannot be your own listing")
    end
  end

  def quantity_cannot_exceed_available_stock
    return unless listing && quantity.present?

    requested_quantity = quantity.to_i

    # Allow a buyer to reduce their existing cart quantity.
    if persisted? && requested_quantity <= quantity_in_database.to_i
      return
    end

    unless listing.available_for_purchase? &&
           requested_quantity <= listing.available_quantity
      errors.add(
        :quantity,
        "exceeds the available stock of #{listing.available_quantity} units"
      )
    end
  end
end
