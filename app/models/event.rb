class Event < ApplicationRecord
  belongs_to :event_set
  has_many   :action_choices, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :event_set_id }
  validates :derivation_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :message, :character_image, :background_image, presence: true

  def ordered_action_choices
    action_choices.order(:position)
  end

  def arithmetic_quiz_being_asked?
    event_set.name == "算数" && (1..4).include?(derivation_number)
  end

  def selected_choice(position)
    action_choices.find_by!(position: position)
  end
end
