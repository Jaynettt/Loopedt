
class SellerApplication < ApplicationRecord
  belongs_to :user

  validates :shop_name, presence: true
  validates :description, presence: true
  validates :location, presence: true

  validates :status, presence: true

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= "pending"
  end
end
