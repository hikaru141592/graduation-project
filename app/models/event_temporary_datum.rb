class EventTemporaryDatum < ApplicationRecord
  belongs_to :user

  validates :reception_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :success_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  before_validation :clamp_counts_to_zero

  private

  def clamp_counts_to_zero
    self.reception_count = [reception_count.to_i, 0].max
    self.success_count = [success_count.to_i, 0].max
  end
end
