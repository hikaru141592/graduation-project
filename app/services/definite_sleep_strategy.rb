class DefiniteSleepStrategy
  def initialize(user, current_time, current_time_window)
    @user                 = user
    @current_time         = current_time
    @current_time_window  = current_time_window
  end

  def window_applicable?
    @current_time_window.definitely_asleep?
  end

  def sleep_check
    true
  end
end
