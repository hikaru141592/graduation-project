class PlayState < ApplicationRecord
  belongs_to  :user
  belongs_to  :current_event,   class_name: "Event"
  delegate    :user_status, to: :user

  validates :action_choices_position, numericality: { only_integer: true }, allow_nil: true
  validates :action_results_priority, numericality: { only_integer: true }, allow_nil: true
  validates :current_cut_position,    numericality: { only_integer: true }, allow_nil: true

  TIMEOUT = 2.hours

  def current_choice
    return unless action_choices_position.present?
    current_event.action_choices.find_by(position: action_choices_position)
  end

  def current_action_result
    return unless action_results_priority.present?
    choice = current_choice
    return unless choice
    choice.action_results.find_by(priority: action_results_priority)
  end

  def current_cut
    return unless current_cut_position.present?
    result = current_action_result
    return unless result
    result.cuts.find_by(position: current_cut_position)
  end

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
