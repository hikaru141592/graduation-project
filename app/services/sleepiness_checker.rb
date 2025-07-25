class SleepinessChecker
  STRATEGIES = [
    DefiniteSleepStrategy,
    PossibilitySleepStrategy,
    PossibilityAwakeStrategy
  ]

  def initialize(user)
    @user = user
    @current_time = Time.current
    @current_time_window = SleepWindow.new(@current_time)
  end

  def sleepy_time?
    STRATEGIES.each do |strategy_class|
      strategy = strategy_class.new(@user, @current_time, @current_time_window)
      return strategy.sleep_check if strategy.window_applicable?
    end
    false
  end
end
