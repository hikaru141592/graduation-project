class PlayState < ApplicationRecord
  belongs_to :user
  belongs_to :current_event,   class_name: "Event"

  validates :action_choices_position, numericality: { only_integer: true }, allow_nil: true
  validates :action_results_priority, numericality: { only_integer: true }, allow_nil: true
  validates :current_cut_position,    numericality: { only_integer: true }, allow_nil: true

  TIMEOUT = 2.hours

  def event_timeout?
    updated_at < TIMEOUT.ago
  end
end
