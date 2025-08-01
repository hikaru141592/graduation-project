class UserStatus < ApplicationRecord
  belongs_to  :user
  belongs_to  :current_loop_event_set, class_name: "EventSet", optional: true
  delegate    :play_state,              to: :user
  delegate    :current_event,           to: :play_state
  delegate    :event_set,               to: :current_event
  delegate    :event_category,          to: :event_set

  validates :hunger_value,    :happiness_value,
            :love_value,      :mood_value,
            :sports_value,
            :art_value,       :money,
            :arithmetic,      :arithmetic_effort,
            :japanese,        :japanese_effort,
            :science,         :science_effort,
            :social_studies,  :social_effort,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def clear_loop_status!
    update!(
      current_loop_event_set_id: nil,
      current_loop_started_at:   nil
    )
  end

  def in_loop?
    return false unless current_loop_event_set_id == event_set.id
    current_loop_started_at > event_category.loop_minutes.minutes.ago
  end

  def loop_timeout?
    current_loop_event_set_id.present? && !in_loop?
  end

  def apply_automatic_update!(play_state_updated_at)
    now       = Time.current
    elapsed   = now - play_state_updated_at

    hunger_ticks = (elapsed / 15.minutes).floor
    self.hunger_value -= hunger_ticks if hunger_ticks > 0

    love_ticks = (elapsed / 8.hours).floor
    self.love_value -= love_ticks * 25 if love_ticks > 0

    vitality_ticks = (elapsed / 5.minutes).floor
    self.temp_vitality += vitality_ticks * 10 if vitality_ticks > 0

    self.hunger_value  = [ [ self.hunger_value, 0 ].max, 100 ].min
    self.love_value    = [ [ self.love_value,   0 ].max, 100 ].min
    self.temp_vitality = [ self.temp_vitality, self.vitality ].min

    save!
  end

  def record_loop_start!
    return if event_category.loop_minutes.blank?
    update!(
      current_loop_event_set_id: event_set.id,
      current_loop_started_at: Time.current
    )
  end
end
