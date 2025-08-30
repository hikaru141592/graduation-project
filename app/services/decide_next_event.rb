class DecideNextEvent
  def initialize(user)
    @user         = user
    @user_status  = user.user_status
    @event        = user.play_state.current_event
    @current_set  = @event.event_set
    @result       = user.play_state.current_action_result
    @resolves     = @result.resolves_loop?
  end

  def call
    if @result.next_derivation_number.present?
      next_set, next_event = @result.apply_derivation
    else
      if @resolves
        @user.invalidate_event_category!(@current_set.event_category, 2.hours.from_now)
      end
      if continue_loop?
        next_set = @current_set
        next_event = @event
      else
        @user_status.clear_loop_status!
        next_set, next_event = pick_event_with_set_call_or_default
        @user_status.record_loop_start!(next_set)
      end
    end

    training_next_set, training_next_event = call_training_event_processor
    next_set, next_event = training_next_set, training_next_event if training_next_event.present?

    [ next_set, next_event ]
  end

  private
  def continue_loop?
    return false if @resolves
    @user_status.in_loop?
  end

  def pick_event_with_set_call_or_default
    if @result.calls_event_set_id.present?
      event_set = EventSet.find(@result.calls_event_set_id)
      event = event_set.events.find_by!(derivation_number: 0)
    else
      event_set, event = @user.pick_next_event_set_and_event
    end
    [ event_set, event ]
  end

  def call_training_event_processor
    arithmetic_training_event_processor = ArithmeticTrainingEventProcessor.new(@user, @result)
    a_next_set, a_next_event = arithmetic_training_event_processor.call
    arithmetic_training_event_processor.record_evaluation

    ball_training_event_processor = BallTrainingEventProcessor.new(@user, @result)
    b_next_set, b_next_event = ball_training_event_processor.call
    ball_training_event_processor.record_evaluation

    return [ a_next_set, a_next_event ] if a_next_event.present?
    return [ b_next_set, b_next_event ] if b_next_event.present?
    return [ nil, nil ]
  end
end
