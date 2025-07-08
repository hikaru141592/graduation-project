class ArithmeticTrainingEventProcessor
  MAX_RECEPTIONS = 3

  def initialize(user, result, next_set, next_event)
    @user       = user
    @status     = user.user_status
    @result     = result
    @next_set   = next_set
    @next_event = next_event
    @temp       = user.event_temporary_datum
  end

  def call
    return start_process if start_process?
    return end_process   if end_process?
    return continue_process if continue_process?
    return evaluation if evaluation?

    [ @next_set, @next_event ]
  end

  def record_evaluation
    return unless @result.action_choice.event.event_set.name == "特訓" && [ 2, 3, 4 ].include?(@result.action_choice.event.derivation_number)
    max_cnt = @status.arithmetic_training_max_count.to_i
    if @temp.success_count > max_cnt
      @status.update!(arithmetic_training_max_count: @temp.success_count)
    end
    if @temp.reception_count == @temp.success_count
      elapsed = (@temp.ended_at - @temp.started_at).to_i
      fastest = @status.arithmetic_training_fastest_time
      if fastest.nil? || elapsed < fastest
        @status.update!(arithmetic_training_fastest_time: elapsed)
      end
    end
    @temp.update!(reception_count: 0, success_count: 0, started_at: nil, ended_at: nil, special_condition: nil)
  end

  private

  def start_process?
    @result.action_choice.event.event_set.name == "特訓" &&
    @result.action_choice.event.derivation_number == 0 &&
    @result.action_choice.label == "さんすう" &&
    @result.priority == 1
  end

  def start_process
    @temp.update!(reception_count: 0, success_count: 0, started_at: Time.current, ended_at: nil, special_condition: "算数特訓")
    event_set = EventSet.find(@result.calls_event_set_id)
    event = event_set.events.find_by!(derivation_number: 0)
    [ event_set, event ]
  end

  def end_process?
    @temp.special_condition == "算数特訓" && @temp.ended_at == nil && @result.action_choice.event.derivation_number != 0 && @temp.reception_count >= (MAX_RECEPTIONS - 1)
  end

  def end_process
    @temp.increment!(:reception_count)
    @temp.increment!(:success_count) if @result.action_choice.label == "〈A〉"
    @temp.update!(ended_at: Time.current)
    event_set = EventSet.find_by!(name: "特訓")
    event = event_set.events.find_by!(derivation_number: 1)
    [ event_set, event ]
  end

  def continue_process?
    @temp.special_condition == "算数特訓" && @temp.ended_at == nil && @result.action_choice.event.derivation_number != 0
  end

  def continue_process
    @temp.increment!(:reception_count)
    @temp.increment!(:success_count) if @result.action_choice.label == "〈A〉"
    event_set = @result.action_choice.event.event_set
    random_deriv = rand(1..4)
    event = event_set.events.find_by!(derivation_number: random_deriv)
    [ event_set, event ]
  end

  def evaluation?
    @result.action_choice.event.event_set.name == "特訓" && @result.action_choice.event.derivation_number == 1
  end

  def evaluation
    event_set = EventSet.find_by!(name: "特訓")
    r, s       = @temp.reception_count, @temp.success_count
    ratio      = r.zero? ? 0.0 : s.to_f / r
    derivation = case
    when s == r         then 2
    when ratio >= 0.25  then 3
    else                     4
    end
    event = event_set.events.find_by!(derivation_number: derivation)
    [ event_set, event ]
  end
end
