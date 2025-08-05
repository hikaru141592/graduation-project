class TimeRangeChecker
  def initialize(condition_hash, now: Time.current)
    @condition  = condition_hash
    @now        = now
    @day        = now.to_date.day
  end

  def time_range_met?
    current = @now.hour * 60 + @now.min
    from, to = base_range
    if @condition["offsets_by_day"].present?
      @condition["offsets_by_day"].each do |ob|
        from, to = apply_offset_by_day(ob, from, to)
      end
    end

    log_time_range_debug(from, to)

    if from <= to
      (from <= current) && (current < to)
    else
      (from <= current) || (current < to)
    end
  end

  private

  def base_range
    from = @condition["from_hour"].to_i * 60 + @condition["from_min"].to_i
    to   = @condition["to_hour"].to_i   * 60 + @condition["to_min"].to_i
    [ from, to ]
  end

  def apply_offset_by_day(ob, from, to)
    delta = ((@day + ob["add"].to_i) * ob["mult"].to_i) % ob["mod"].to_i

    case ob["target"]
    when "to_min"
      to   = (to   + delta) % (24 * 60)
    when "from_min"
      from = (from + delta) % (24 * 60)
    end

    [ from, to ]
  end

  def log_time_range_debug(from, to)
    current_h    = @now.hour
    current_min  = @now.min
    from_h, from_m = from.divmod(60)
    to_h,   to_m   = to.divmod(60)
    Rails.logger.debug(
      "[EventSetSelector] time_range: " \
      "from=#{from_h}:#{format('%02d', from_m)} " \
      "to=#{to_h}:#{format('%02d', to_m)} " \
      "current=#{current_h}:#{format('%02d', current_min)}"
    )
  end
end
