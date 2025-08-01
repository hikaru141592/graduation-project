class EventSetSelector
  PRIORITY_LIST = [
    "寝ている",
    "寝起き",
    "眠そう",
    "泣いている(空腹)",
    "泣いている(よしよし不足)",
    "泣いている(ランダム)",
    "年始",
    "踊っている",
    "占い",
    "花見",
    "紅葉",
    "タマモン",
    "タマえもん",
    "ニワトリビアの湖",
    "扇風機",
    "こたつ",
    "ブロックのおもちゃに夢中",
    "マンガに夢中",
    "何かしたそう",
    "何か言っている"
  ].freeze

  def initialize(user)
    @user       = user
    @status     = user.user_status
    @event_sets = EventSet.all.to_a

    cleanup_event_set_old_limit_counts
    filter_invalid_categories!
    filter_daily_limits!
  end

  def select_next
    PRIORITY_LIST.each do |name|
      set = @event_sets.find { |s| s.name == name }
      next unless set
      conds = set.trigger_conditions
      if conditions_met?(conds)
        record_occurrence(set)
        return set
      end
    end

    @event_sets.find { |s| s.name == "何か言っている" }
  end

  private

  def cleanup_event_set_old_limit_counts
    DailyLimitEventSetCount.where(user: @user).where("occurred_on < ?", Date.current).delete_all
  end

  def filter_daily_limits!
    @event_sets.reject! do |set|
      limit = set.daily_limit
      next false if limit.nil?
      today_count(set) >= limit
    end
  end

  def today_count(set)
    rec = DailyLimitEventSetCount.find_by(user: @user, event_set: set, occurred_on: Date.current)
    rec&.count.to_i
  end

  def record_occurrence(set)
    return if set.daily_limit.nil?
    rec = DailyLimitEventSetCount.find_or_initialize_by(user: @user, event_set: set, occurred_on: Date.current)
    rec.count += 1
    rec.save!
  end

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
        time_range_met?(c)
      when "weekday"
        today = Date.current.wday
        c["value"].include?(today)
      when "date_range"
        date_range_met?(c)
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

  def time_range_met?(c)
    now = Time.zone.now
    current = now.hour * 60 + now.min
    from, to = base_range(c)
    if c["offsets_by_day"].present?
      c["offsets_by_day"].each do |ob|
        from, to = apply_offset_by_day(ob, from, to)
      end
    end

    # デバッグ用
    current_h    = now.hour
    current_min  = now.min
    from_h, from_m = from.divmod(60)
    to_h,   to_m   = to.divmod(60)
    Rails.logger.debug(
      "[EventSetSelector] time_range: " \
      "from=#{from_h}:#{format('%02d', from_m)} " \
      "to=#{to_h}:#{format('%02d', to_m)} " \
      "current=#{current_h}:#{format('%02d', current_min)}"
    )

    if from <= to
      (from <= current) && (current < to)
    else
      (from <= current) || (current < to)
    end
  end

  def base_range(c)
    from = c["from_hour"].to_i * 60 + c["from_min"].to_i
    to   = c["to_hour"].to_i   * 60 + c["to_min"].to_i
    [ from, to ]
  end

  def apply_offset_by_day(ob, from, to)
    day   = Time.zone.today.day
    delta = ((day + ob["add"].to_i) * ob["mult"].to_i) % ob["mod"].to_i

    case ob["target"]
    when "to_min"
      to   = (to   + delta) % (24 * 60)
    when "from_min"
      from = (from + delta) % (24 * 60)
    end

    [ from, to ]
  end

  def date_range_met?(c)
    today = Date.current
    from  = Date.new(today.year, c["from"]["month"], c["from"]["day"])
    to    = Date.new(today.year, c["to"]["month"],   c["to"]["day"])
    to    = to.next_year if from > to
    (from..to).cover?(today)
  end
end
