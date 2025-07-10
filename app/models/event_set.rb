class EventSet < ApplicationRecord
  belongs_to :event_category
  has_many :events, dependent: :destroy
  has_many :daily_limit_event_set_counts, dependent: :destroy
  has_many :users_who_counted, through: :daily_limit_event_set_counts, source: :user

  validates :name, presence: true, uniqueness: { scope: :event_category_id }
  validates :trigger_conditions, presence: true
end
