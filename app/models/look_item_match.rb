
class LookItemMatch < ApplicationRecord
  belongs_to :look_item
  belongs_to :listing

  validates :match_score,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            },
            allow_nil: true
end
