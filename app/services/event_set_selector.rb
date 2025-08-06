class EventSetSelector
  PRIORITY_LIST = [
    "寝ている",
    "寝起き",
    "眠そう",
    "泣いている(空腹)",
    "泣いている(よしよし不足)",
    "泣いている(ランダム)",
    "年始",
    "誕生日",
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
    "ボーっとしている",
    "ニコニコしている",
    "ゴロゴロしている",
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
      if event_triggerable?(set)
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

  def event_triggerable?(set)
    ConditionEvaluator.new(@user, set.trigger_conditions, now: Time.current).conditions_met? || (set.name == "誕生日" && @user.birthday?)
  end

  def record_occurrence(set)
    return if set.daily_limit.nil?
    rec = DailyLimitEventSetCount.find_or_initialize_by(user: @user, event_set: set, occurred_on: Date.current)
    rec.count += 1
    rec.save!
  end

  def filter_invalid_categories!
    invalid_ids = @user.user_event_category_invalidations.pluck(:event_category_id)
    @event_sets.reject! { |s| invalid_ids.include?(s.event_category_id) }
  end
end
