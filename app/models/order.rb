class Order < ApplicationRecord
  belongs_to :listing

  belongs_to :buyer,
             class_name: "User"

  belongs_to :seller,
             class_name: "User"

  belongs_to :checkout, optional: true

  validates :amount,
            presence: true,
            numericality: { greater_than: 0 }

  validates :status, presence: true
end
