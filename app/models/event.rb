class Event < ApplicationRecord
  belongs_to :event_set
  has_many   :action_choices, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :event_set_id }
  validates :derivation_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :message, :character_image, :background_image, presence: true
end
