
class LookItem < ApplicationRecord
  belongs_to :look

  has_many :look_item_matches, dependent: :destroy

  validates :category, presence: true
  validates :description, presence: true
end
