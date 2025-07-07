class UserStatus < ApplicationRecord
  belongs_to :user
  belongs_to :current_loop_event_set, class_name: "EventSet", optional: true

  validates :hunger_value,    :happiness_value,
            :love_value,      :mood_value,
            :sports_value,
            :art_value,       :money,
            :arithmetic,      :arithmetic_effort,
            :japanese,        :japanese_effort,
            :science,         :science_effort,
            :social_studies,  :social_effort,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
