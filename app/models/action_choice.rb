class ActionChoice < ApplicationRecord
  belongs_to :event
  has_many   :action_results, dependent: :destroy

  validates :position, presence: true, numericality: { only_integer: true }, inclusion: { in: 1..4 }
  validates :label,    presence: true

  def selected_result(user)
    ordered  = action_results.order(:priority).to_a
    result   = ordered.detect { |ar| ConditionEvaluator.new(user, ar.trigger_conditions).conditions_met? }
    result ||= ordered.first
  end
end
