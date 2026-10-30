class Checkout < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  has_many :orders, dependent: :restrict_with_error

  validates :subtotal, :service_fee, :payment_fee, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }

  validates :status, presence: true

  STATUSES = %w[pending paid failed].freeze

  validates :status, inclusion: { in: STATUSES }
end
