class SellerApplication < ApplicationRecord
  belongs_to :user

  has_one_attached :identity_document
  has_one_attached :proof_of_address

  encrypts :id_number

  validates :shop_name, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :status, presence: true,
                     inclusion: { in: %w[draft pending approved rejected] }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= "draft"
  end
end
