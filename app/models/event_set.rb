class EventSet < ApplicationRecord
  belongs_to :event_category
  has_many :events, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :event_category_id }
  validates :trigger_conditions, presence: true
end
