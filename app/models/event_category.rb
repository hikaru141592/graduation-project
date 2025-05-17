class EventCategory < ApplicationRecord
  has_many :event_sets, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :loop_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
