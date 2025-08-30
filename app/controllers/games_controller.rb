class GamesController < ApplicationController
  require "time"

  def play
    # apply_automatic_update!によるステータス更新が適切に行われなくなるため@play_state.touchはしない
    # @play_state.apply_automatic_update!はしない
    @play_state = current_user.play_state
    @user_status = current_user.user_status
    EventTimeout.new(@play_state, @user_status, request.headers).handle_timeouts
    @presenter = GameViewPresenter.new(@play_state)
  end

  def select_action
    play_state = current_user.play_state
    return if redirect_if_old_timestamp!(play_state, false)

    play_state.apply_automatic_update!

    event    = play_state.current_event
    position = params.require(:position).to_i
    choice   = event.selected_choice(position)
    result   = choice.selected_result(current_user)

    # イントロダクションイベントでのみ適用
    current_user.name_suffix_change!(event, position)

    first_cut_or_next_event!(play_state, position, result)
  end

  def advance_cut(skip_check: false)
    play_state = current_user.play_state
    # select_actionでカット数0で呼び出された場合はタイムスタンプチェックをスキップする
    return if redirect_if_old_timestamp!(play_state, skip_check)

    next_cut_position = play_state.current_cut_position.to_i + 1
    result   = play_state.current_action_result

    return handle_next_cut(play_state, next_cut_position) if result.cuts.exists?(position: next_cut_position)

    # 以下は、次のcutがなく次のイベント選定を行い遷移する処理
    apply_effects!(result.effects)
    play_state.apply_automatic_update!
    current_user.clear_event_category_invalidations!

    next_set, next_event = DecideNextEvent.new(current_user).call
    play_state.start_new_event!(next_event)
    redirect_to root_path
  end

  private
  def handle_next_cut(play_state, next_cut)
    play_state.apply_automatic_update!
    play_state.update!(current_cut_position: next_cut)
    redirect_to root_path
  end

  def apply_effects!(effects)
    status = current_user.user_status
    (effects["status"] || []).each do |e|
      attr  = e["attribute"]
      delta = e["delta"].to_i
      new_value = status[attr] + delta
      new_value = [ new_value, 0 ].max
      if [ "hunger_value", "love_value", "mood_value" ].include?(attr)
        new_value = [ new_value, 100 ].min
      end
      new_value = [ new_value, 99_999_999 ].min
      status[attr] = new_value
    end
    status.save!

    #    event_temporary_data = current_user.event_temporary_datum
    #    (effects["event_temporary_data"] || []).each do |e|
    #      attr  = e["attribute"]
    #      delta = e["delta"].to_i
    #      new_value = event_temporary_data[attr] + delta
    #      new_value = [ new_value, 0 ].max
    #      new_value = [ new_value, 20 ].min
    #      event_temporary_data[attr] = new_value
    #    end
    #    event_temporary_data.save!
  end

  def redirect_if_old_timestamp!(play_state, skip_check = false)
    return false if skip_check || Rails.env.test?

    client_ts = Time.iso8601(params.require(:state_timestamp)).to_i
    server_ts = play_state.updated_at.to_i

    if client_ts < server_ts
      redirect_to root_path and return true
    else
      false
    end
  end

  def first_cut_or_next_event!(play_state, position, result)
    attrs = { action_choices_position: position, action_results_priority: result.priority }
    if result.cuts.exists?
      play_state.update!(attrs.merge(current_cut_position: 1))
      redirect_to root_path and return
    else
      play_state.update!(attrs.merge(current_cut_position: nil))
      advance_cut(skip_check: true)
    end
  end
end
