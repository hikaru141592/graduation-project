class PossibilitySleepStrategy
  def initialize(user, current_time, current_time_window)
    @user                 = user
    @current_time         = current_time
    @current_time_window  = current_time_window
  end

  def window_applicable?
    @current_time_window.possibility_of_slept?
  end

  def sleep_check
    updated_time   = @user.play_state.updated_at
    updated_window = SleepWindow.new(updated_time)

    if before_midnight?
      handle_before_midnight(updated_time, updated_window)
    else
      handle_after_midnight(updated_time, updated_window)
    end
  end

  private

  def before_midnight?
    @current_time.hour >= 12
  end

  def handle_before_midnight(updated_time, updated_window)
    if play_state_updated_tonight?(updated_time, updated_window)
      handle_asleep_or_awake
    else
      false
    end
  end

  def play_state_updated_tonight?(updated_time, updated_window)
    updated_time.to_date == Date.current && updated_window.possibility_of_slept_start?
  end

  def handle_asleep_or_awake
    category_name = @user.play_state.current_event.event_set.event_category.name
    %w[寝ている 寝かせた].include?(category_name)
  end

  def handle_after_midnight(updated_time, updated_window)
    if play_state_updated_last_night?(updated_time, updated_window)
      handle_asleep_or_awake
    else
      false
    end
  end

  def play_state_updated_last_night?(updated_time, updated_window)
    updated_time.to_date == Date.current || (updated_time.to_date == (Date.current - 1) && updated_window.possibility_of_slept_start?)
  end
end
