
class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_many_attached :images

  has_many :favorites, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :cart_items, dependent: :destroy
  has_many :look_item_matches, dependent: :destroy

  before_validation :sync_status_with_stock

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :condition, presence: true
  validates :status, presence: true

  validates :stock_quantity,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :reserved_quantity,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :reserved_stock_cannot_exceed_total_stock

  validates :minimum_negotiable_price,
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: :price
            },
            allow_nil: true

  def available_quantity
    stock_quantity.to_i - reserved_quantity.to_i
  end

  def available_for_purchase?
    status == "available" && available_quantity.positive?
  end

  private

  def reserved_stock_cannot_exceed_total_stock
    return if stock_quantity.nil? || reserved_quantity.nil?

    if reserved_quantity > stock_quantity
      errors.add(:reserved_quantity, "cannot exceed total stock")
    end
  end

  def sync_status_with_stock
    if stock_quantity == 0
      self.status = "sold"
    elsif status == "sold" && stock_quantity.positive?
      self.status = "available"
    end
  end
end
