class ActionChoice < ApplicationRecord
  belongs_to :event
  has_many   :action_results, dependent: :destroy

  validates :position, presence: true, numericality: { only_integer: true }, inclusion: { in: 1..4 }
  validates :label,    presence: true

  def selected_result(user)
    result   = action_results.order(:priority).detect { |ar| conditions_met?(ar.trigger_conditions, user) }
    result ||= action_results.order(:priority).first
  end

  private
  def conditions_met?(conds, user)
    return true if conds["always"] == true
    op   = conds["operator"] || "and"
    list = conds["conditions"] || []
    results = list.map do |c|
      case c["type"]
      when "status"
        user.user_status.public_send(c["attribute"]).public_send(c["operator"], c["value"])
      when "probability"
        rand(100) < c["percent"]
      when "item"
        user.user_items.find_by(code: c["item_code"]).try(:count).to_i.public_send(c["operator"], c["value"])
      when "event_temporary_data"
        user.event_temporary_datum.public_send(c["attribute"]).public_send(c["operator"], c["value"])
      else
        false
      end
    end
    op == "and" ? results.all? : results.any?
  end
end
