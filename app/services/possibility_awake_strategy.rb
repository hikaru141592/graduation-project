class PossibilityAwakeStrategy
  def initialize(user, current_time, current_time_window)
    @user                 = user
    @current_time         = current_time
    @current_time_window  = current_time_window
  end

  def window_applicable?
    @current_time_window.possibility_of_not_awake?
  end

  def sleep_check
    updated_time = @user.play_state.updated_at
    if updated_time.to_date == Date.current && SleepWindow.new(updated_time).possibility_of_not_awake_start?
      handle_asleep_or_awake
    else
      true
    end
  end

  private

  def handle_asleep_or_awake
    category_name = @user.play_state.current_event.event_set.event_category.name
    %w[寝ている 寝かせた].include?(category_name)
  end
end
