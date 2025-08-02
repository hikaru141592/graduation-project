class PlayState < ApplicationRecord
  belongs_to  :user
  belongs_to  :current_event,   class_name: "Event"
  delegate    :user_status, to: :user

  validates :action_choices_position, numericality: { only_integer: true }, allow_nil: true
  validates :action_results_priority, numericality: { only_integer: true }, allow_nil: true
  validates :current_cut_position,    numericality: { only_integer: true }, allow_nil: true

  TIMEOUT = 2.hours

  def event_timeout?
    updated_at < TIMEOUT.ago
  end

  def start_new_event!(next_event)
    update!(
      current_event_id:        next_event.id,
      action_choices_position: nil,
      action_results_priority: nil,
      current_cut_position:    nil
    )
  end

  def apply_automatic_update!
    user_status.apply_automatic_update!(updated_at)
    touch
  end
end
