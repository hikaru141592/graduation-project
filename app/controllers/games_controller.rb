class GamesController < ApplicationController
  def play
    @play_state = current_user.play_state
    @event = @play_state.current_event
    if @play_state.current_cut_position.present?
      choice = @event.action_choices.find_by!(position: @play_state.action_choices_position)
      @action_result = choice.action_results.find_by!(priority: @play_state.action_results_priority)
      @cut = @action_result.cuts.find_by!(position: @play_state.current_cut_position)
      @phase = :cut
    else
      @choices = @event.action_choices.order(:position)
      @phase = :select
    end
  end

  def select_action
    play_state = current_user.play_state
    event = play_state.current_event
    position = params.require(:position).to_i
    choice = event.action_choices.find_by!(position: position)

    result = choice.action_results.
      order(:priority).
      detect { |ar| conditions_met?(ar.trigger_conditions, current_user.user_status) }

    result ||= choice.action_results.order(priority: :desc).first

    play_state.update!(
      action_choices_position: position,
      action_results_priority: result.priority,
      current_cut_position:    1
    )

    redirect_to root_path
  end

  def advance_cut
    play_state = current_user.play_state
    current = play_state.current_cut_position.to_i
    next_cut = current + 1
    event   = play_state.current_event
    choice  = event.action_choices.find_by!(position: play_state.action_choices_position)
    result  = choice.action_results.find_by!(priority: play_state.action_results_priority)

    if result.cuts.exists?(position: next_cut)
      play_state.update!(current_cut_position: next_cut)
    else
      fixed_set   = EventSet.find_by!(name: '何かしたそう')
      fixed_event = Event.find_by!(event_set: fixed_set, derivation_number: 0)

      play_state.update!(
        current_event_id:        fixed_event.id,
        action_choices_position: nil,
        action_results_priority: nil,
        current_cut_position:    nil
      )
    end

    redirect_to root_path
  end

  private

  # モデル移動可
  def conditions_met?(conds, status)
    return true if conds["always"] == true
    op   = conds["operator"] || "and"
    list = conds["conditions"] || []
    results = list.map do |c|
      case c["type"]
      when "status"
        status.send(c["attribute"]).public_send(c["operator"], c["value"])
      when "probability"
        rand(100) < c["percent"]
      when "item"
        current_user.user_items.find_by(code: c["item_code"]).try(:count).to_i.public_send(c["operator"], c["value"])
      else
        false
      end
    end
    op == "and" ? results.all? : results.any?
  end
end
