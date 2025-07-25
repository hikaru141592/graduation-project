class SleepinessChecker
  # 余裕があればStrategy Patternでの切り出しを

  def initialize(user)
    @user = user
    @window = SleepWindow.new
  end

  def sleepy_time?
    return true                             if @window.definitely_asleep?
    return handle_possibility_of_slept      if @window.possibility_of_slept?
    return handle_possibility_of_not_awake  if @window.possibility_of_not_awake?
    false
  end

  private

  def handle_possibility_of_slept
    if before_midnight?
      handle_before_midnight
    else
      handle_after_midnight
    end
  end

  def before_midnight?
    Time.current.hour >= 12
  end

  def handle_before_midnight
    if play_state_updated_tonight?
      handle_asleep_or_awake
    else
      false
    end
  end

  def play_state_updated_tonight?
    updated_time = @user.play_state.updated_at
    updated_time.to_date == Date.current && SleepWindow.new(updated_time).possibility_of_slept_start?
  end

  def handle_asleep_or_awake
    category_name = @user.play_state.current_event.event_set.event_category.name
    %w[寝ている 寝かせた].include?(category_name)
  end

  def handle_after_midnight
    if play_state_updated_last_night?
      handle_asleep_or_awake
    else
      false
    end
  end

  def play_state_updated_last_night?
    updated_time = @user.play_state.updated_at
    updated_time.to_date == Date.current || (updated_time.to_date == (Date.current - 1) && SleepWindow.new(updated_time).possibility_of_slept_start?)
  end

  def handle_possibility_of_not_awake
    updated_time = @user.play_state.updated_at
    if updated_time.to_date == Date.current && SleepWindow.new(updated_time).possibility_of_not_awake_start?
      handle_asleep_or_awake
    else
      true
    end
  end
end
