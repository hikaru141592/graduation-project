class EventSetSelector
  PRIORITY_LIST = [
    "寝ている",
    "泣いている(空腹)",
    "泣いている(よしよし不足)",
    "泣いている(ランダム)",
    "踊っている",
    "何かしたそう",
    "何か言っている"
  ].freeze

  def initialize(user)
    @user       = user
    @status     = user.user_status
    @event_sets = EventSet.all.to_a

    filter_invalid_categories!
  end

  def select_next
    PRIORITY_LIST.each do |name|
      set = @event_sets.find { |s| s.name == name }
      next unless set
      conds = set.trigger_conditions
      return set if conditions_met?(conds)
    end

    @event_sets.find { |s| s.name == "何か言っている" }
  end

  private

  def conditions_met?(conds)
    return true if conds["always"] == true

    op   = conds["operator"] || "and"
    list = conds["conditions"] || []

    results = list.map do |c|
      case c["type"]
      when "status"
        @status
          .public_send(c["attribute"])
          .public_send(c["operator"], c["value"])
      when "probability"
        rand(100) < c["percent"]
      when "item"
        @user.user_items
             .find_by(code: c["item_code"])
             .try(:count).to_i
             .public_send(c["operator"], c["value"])
      when "time_range"
        now = Time.zone.now
        current_total_min = now.hour * 60 + now.min
        from_total_min = c["from_hour"].to_i * 60 + c["from_min"].to_i
        to_total_min   = c["to_hour"].to_i   * 60 + c["to_min"].to_i
        if from_total_min <= to_total_min
          (from_total_min <= current_total_min) && (current_total_min < to_total_min)
        else
          (from_total_min <= current_total_min) || (current_total_min < to_total_min)
        end
      else
        false
      end
    end

    op == "and" ? results.all? : results.any?
  end

  def filter_invalid_categories!
    invalid_ids = @user.user_event_category_invalidations.pluck(:event_category_id)
    @event_sets.reject! { |s| invalid_ids.include?(s.event_category_id) }
  end
end
