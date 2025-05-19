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
end
