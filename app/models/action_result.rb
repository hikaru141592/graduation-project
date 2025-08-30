class ActionResult < ApplicationRecord
  belongs_to :action_choice
  belongs_to :calls_event_set, class_name: "EventSet", optional: true

  has_many :cuts, dependent: :destroy

  validates :priority, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :trigger_conditions, presence: true
  validate  :exclusive_derivation_or_call

  def apply_derivation
    event_set = action_choice.event.event_set
    begin
      derived_event = event_set.events.find_by!(derivation_number: next_derivation_number)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Derivation event not found: set=#{event_set.id}, num=#{next_derivation_number}"
      derived_event = event_set.events.find_by!(derivation_number: 0)
    end
    [ event_set, derived_event ]
  end

  private

  def exclusive_derivation_or_call
    if next_derivation_number.present? && calls_event_set_id.present?
      errors.add(:base, "派生番号かイベントセットコールのどちらか一方のみ指定してください")
    end
  end
end
