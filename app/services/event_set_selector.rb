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
    "元気ない？",
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
    "今日はどんな予定？",
    "今日はどんな一日だった？",
    "自慢話",
    "うしろ！",
    "たすけてくれる",
    "ヒマなの？",
    "オムライス",
    "ラーメン",
    "野菜",
    "ぼくかっこいい",
    "なんかいいこと",
    "てんさい",
    "仲直り",
    "最近どこか行った？",
    "最近なにかがんばってる？",
    "つらいことがあったとき",
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
    counts_by_set = DailyLimitEventSetCount.where(user: @user, occurred_on: Date.current).pluck(:event_set_id, :count).to_h

    @event_sets.reject! do |set|
      limit = set.daily_limit
      next false if limit.nil?
      (counts_by_set[set.id] || 0) >= limit
    end
  end

  def event_triggerable?(set)
    ConditionEvaluator.new(@user, set.trigger_conditions, now: Time.current).conditions_met? || (set.name == "誕生日" && @user.birthday?)
  end

  def record_occurrence(set)
    return if set.daily_limit.nil?
    return if record_occurrence_skip?
    rec = DailyLimitEventSetCount.find_or_initialize_by(user: @user, event_set: set, occurred_on: Date.current)
    rec.count += 1
    rec.save!
  end

  def record_occurrence_skip?
    result = @user.play_state.current_action_result
    return false if result.nil?
    return false if result.action_choice.event.event_set.name == "特訓" && [ 2, 3, 4, 5, 6 ].include?(result.action_choice.event.derivation_number)

    [ "算数特訓", "ボール遊び特訓" ].include?(@user.event_temporary_datum.special_condition)
  end

  def filter_invalid_categories!
    invalid_ids = @user.user_event_category_invalidations.pluck(:event_category_id)
    @event_sets.reject! { |s| invalid_ids.include?(s.event_category_id) }
  end
end
