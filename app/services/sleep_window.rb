class SleepWindow
  def initialize(time = Time.current)
    @time = time
  end

  def definitely_asleep?
    definitely_slept? && definitely_not_awake?
  end

  def definitely_slept?
    @time.hour > 1 || (@time.hour == 1 && @time.min >= 58)
  end

  def definitely_not_awake?
    @time.hour < 6 || (@time.hour == 6 && @time.min < 38)
  end

  def possibility_of_slept?
    possibility_of_slept_start? || possibility_of_slept_end?
  end

  def possibility_of_slept_start?
    @time.hour > 22 || (@time.hour == 22 && @time.min >= 14)
  end

  def possibility_of_slept_end?
    !definitely_slept?
  end

  def possibility_of_not_awake?
    possibility_of_not_awake_start? && possibility_of_not_awake_end?
  end

  def possibility_of_not_awake_start?
    !definitely_not_awake?
  end

  def possibility_of_not_awake_end?
    @time.hour < 8 || (@time.hour == 8 && @time.min < 53)
  end
end
