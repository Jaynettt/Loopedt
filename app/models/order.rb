
class Order < ApplicationRecord
  belongs_to :listing

  belongs_to :buyer,
             class_name: "User"

  belongs_to :seller,
             class_name: "User"

  belongs_to :checkout, optional: true

  belongs_to :delivery_person,
             class_name: "User",
             optional: true

  validates :amount,
            presence: true,
            numericality: { greater_than: 0 }

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }

  validates :status, presence: true

  DELIVERY_STATUSES = %w[
    pending
    ready_for_dispatch
    assigned
    picked_up
    out_for_delivery
    delivered
    accepted
    refused
    disputed
  ].freeze

  validates :delivery_status,
            inclusion: { in: DELIVERY_STATUSES }

  before_validation :generate_acceptance_code, on: :create

  private

  def generate_acceptance_code
    self.acceptance_code ||= SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")
  end
end
