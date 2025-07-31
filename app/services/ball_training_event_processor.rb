class BallTrainingEventProcessor
  MAX_ALLOWED_MISTAKES = 3

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
    if continue_process?
      statuses = @result.effects["status"] || []
      @temp.increment!(:reception_count)
      @temp.increment!(:success_count) if statuses.any? { |status| status["attribute"] == "sports_value" }
      return end_process   if end_process?
      return continue_process
    end
    return evaluation if evaluation?

    [ @next_set, @next_event ]
  end

  def record_evaluation
    return unless @result.action_choice.event.event_set.name == "特訓" && [ 5, 6 ].include?(@result.action_choice.event.derivation_number)
    max_cnt = @status.arithmetic_training_max_count.to_i
    if @temp.success_count > max_cnt
      @status.update!(ball_training_max_count: @temp.success_count)
    end
    @temp.update!(reception_count: 0, success_count: 0, started_at: nil, ended_at: nil, special_condition: nil)
  end

  private

  def start_process?
    @result.action_choice.event.event_set.name == "特訓" &&
    @result.action_choice.event.derivation_number == 0 &&
    @result.action_choice.label == "ボールあそび" &&
    @result.priority == 1
  end

  def start_process
    @temp.update!(reception_count: 0, success_count: 0, started_at: Time.current, ended_at: nil, special_condition: "ボール遊び特訓")
    event_set = EventSet.find(@result.calls_event_set_id)
    event = event_set.events.find_by!(derivation_number: 0)
    [ event_set, event ]
  end

  def end_process?
    @temp.reception_count >= (MAX_ALLOWED_MISTAKES - 1)
    (@temp.reception_count - @temp.success_count) >= MAX_ALLOWED_MISTAKES
  end

  def end_process
    @temp.update!(ended_at: Time.current)
    event_set = EventSet.find_by!(name: "特訓")
    event = event_set.events.find_by!(derivation_number: 1)
    [ event_set, event ]
  end

  def continue_process?
    @temp.special_condition == "ボール遊び特訓" && @temp.ended_at == nil && ![ 0, 1 ].include?(@result.action_choice.event.derivation_number)
  end

  def continue_process
    event_set = @result.action_choice.event.event_set
    event = event_set.events.find_by!(derivation_number: 0)
    [ event_set, event ]
  end

  def evaluation?
    @result.action_choice.event.event_set.name == "特訓" && @result.action_choice.event.derivation_number == 1
  end

  def evaluation
    event_set = EventSet.find_by!(name: "特訓")
    derivation = @temp.success_count >= 3 ? 5 : 6
    event = event_set.events.find_by!(derivation_number: derivation)
    [ event_set, event ]
  end
end
