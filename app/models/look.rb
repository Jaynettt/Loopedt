
class Look < ApplicationRecord
  belongs_to :user

  has_one_attached :inspiration_image

  has_many :look_items, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: {
    in: %w[uploaded analyzing completed failed]
  }
end
