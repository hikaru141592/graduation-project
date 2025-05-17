class ActionResult < ApplicationRecord
  belongs_to :action_choice
  belongs_to :calls_event_set, class_name: "EventSet", optional: true

  has_many :cuts, dependent: :destroy

  validates :priority, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :trigger_conditions, presence: true
  validate  :exclusive_derivation_or_call

  private

  # next_derivation_number と calls_event_set_id は同時に存在しないよう検証
  def exclusive_derivation_or_call
    if next_derivation_number.present? && calls_event_set_id.present?
      errors.add(:base, "派生番号かイベントセットコールのどちらか一方のみ指定してください")
    end
  end
end
