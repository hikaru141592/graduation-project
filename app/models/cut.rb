class Cut < ApplicationRecord
  belongs_to :action_result

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :message, :character_image, :background_image, presence: true
end
