class Cut < ApplicationRecord
  belongs_to :action_result

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :message, :character_image, :background_image, presence: true

  def random_message(seed_time)
    return message if messages.blank?
    seed_value = seed_time.to_i
    rng = Random.new(seed_value)
    messages.sample(random: rng)
  end
end
