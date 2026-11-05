
class Checkout < ApplicationRecord
  belongs_to :buyer, class_name: "User"

  has_many :orders, dependent: :restrict_with_error

  STATUSES = %w[pending paid failed].freeze
  RESERVATION_DURATION = 30.minutes

  validates :subtotal, :service_fee, :payment_fee, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  # Releases reserved stock when payment fails or checkout expires.
  def release_inventory!
    released = false

    self.class.transaction do
      with_lock do
        if status == "pending"
          inventory_valid = true

          orders.includes(:listing).order(:listing_id).each do |order|
            order.listing.with_lock do
              listing = order.listing

              if listing.reserved_quantity < order.quantity
                inventory_valid = false
                raise ActiveRecord::Rollback
              end

              listing.update!(
                reserved_quantity: listing.reserved_quantity - order.quantity
              )
            end
          end

          if inventory_valid
            update!(status: "failed")
            released = true
          end
        end
      end
    end

    released
  end

  # Converts reserved stock into sold stock after payment confirmation.
  def complete_payment!
    completed = false

    self.class.transaction do
      with_lock do
        if status == "paid"
          completed = true

        elsif status == "pending" && !expired?
          inventory_valid = true

          orders.includes(:listing).order(:listing_id).each do |order|
            order.listing.with_lock do
              listing = order.listing

              if listing.reserved_quantity < order.quantity ||
                 listing.stock_quantity < order.quantity
                inventory_valid = false
                raise ActiveRecord::Rollback
              end

              listing.update!(
                stock_quantity: listing.stock_quantity - order.quantity,
                reserved_quantity: listing.reserved_quantity - order.quantity
              )
            end
          end

          if inventory_valid
            update!(status: "paid")
            orders.update_all(
              status: "paid",
              updated_at: Time.current
            )
            completed = true
          end
        end
      end
    end

    completed
  end
end
