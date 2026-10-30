
class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_many_attached :images

  has_many :favorites, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :cart_items, dependent: :destroy

  has_many :look_item_matches, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :condition, presence: true
  validates :status, presence: true
end
