class EventTimeout
  def initialize(play_state, user_status, headers)
    @user        = user_status.user
    @play_state  = play_state
    @user_status = user_status
    @headers     = headers
  end

  def handle_timeouts
    return if turbo_request?
    return unless timeout?
    execute_timeout_flow
  end

  private

  def turbo_request?
    @headers["Turbo-Visit"].present? || @headers["Turbo-Frame"].present?
  end

  def timeout?
    current_set = @play_state.current_event.event_set
    @user_status.loop_timeout? || normal_event_timeout?
  end

  def normal_event_timeout?
    @user_status.current_loop_event_set_id.blank? && @play_state.event_timeout?
  end

  def execute_timeout_flow
    @play_state.apply_automatic_update!
    @user.clear_event_category_invalidations!
    @user_status.clear_loop_status!
    next_set, next_event = @user.pick_next_event_set_and_event
    @user_status.record_loop_start!
    @play_state.start_new_event!(next_event)
  end
end
