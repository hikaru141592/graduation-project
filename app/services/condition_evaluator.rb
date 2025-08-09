class ConditionEvaluator
  def initialize(user, conditions, now: Time.current)
    @user = user
    @status = user.user_status
    @conditions  = conditions
    @now        = now
    @date        = now.to_date
  end

  def conditions_met?
    return true if @conditions["always"] == true

    op   = @conditions["operator"] || "and"
    list = @conditions["conditions"] || []

    results = list.map do |c|
      case c["type"]
      when "status"       then status_judge?(c)
      when "probability"  then probability_judge?(c)
      when "item"         then item_judge?(c)
      when "time_range"   then TimeRangeChecker.new(@user, c, now: @now).time_range_met?
      when "weekday"      then weekday_judge?(c)
      when "date_range"   then date_range_judge?(c)
      else false
      end
    end

    op == "and" ? results.all? : results.any?
  end

  private

  def status_judge?(c)
    @status.public_send(c["attribute"]).public_send(c["operator"], c["value"])
  end

  def probability_judge?(c)
    rand(100) < c["percent"]
  end

  def item_judge?(c)
    @user.user_items
      .find_by(code: c["item_code"])
      .try(:count).to_i
      .public_send(c["operator"], c["value"])
  end

  def weekday_judge?(c)
    weekday = @date.wday
    c["value"].include?(weekday)
  end

  def date_range_judge?(c)
    from  = Date.new(@date.year, c["from"]["month"], c["from"]["day"])
    to    = Date.new(@date.year, c["to"]["month"],   c["to"]["day"])
    to    = to.next_year if from > to
    (from..to).cover?(@date)
  end
end
