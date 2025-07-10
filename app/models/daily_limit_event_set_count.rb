class DailyLimitEventSetCount < ApplicationRecord
  belongs_to :user
  belongs_to :event_set

  validates :occurred_on, presence: true
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end