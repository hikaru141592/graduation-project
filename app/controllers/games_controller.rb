class GamesController < ApplicationController
  def play
    @play_state = current_user.play_state
    # apply_automatic_decay!(@play_state)

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
    apply_automatic_decay!(play_state)

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
      apply_automatic_decay!(play_state)
      play_state.update!(current_cut_position: next_cut)
    else
      apply_effects!(result.effects)
      apply_automatic_decay!(play_state)

      selector   = EventSetSelector.new(current_user)
      next_set   = selector.select_next
      next_event = next_set.events.find_by!(derivation_number: 0)

      play_state.update!(
        current_event_id:        next_event.id,
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

  def apply_effects!(effects)
    status = current_user.user_status

    (effects["status"] || []).each do |e|
      attr  = e["attribute"]
      delta = e["delta"].to_i
      new_value = status[attr] + delta
      new_value = [ new_value, 0 ].max
      unless [ "happiness_value", "money" ].include?(attr)
        new_value = [ new_value, 100 ].min
      end
      new_value = [ new_value, 99_999_999 ].min
      status[attr] = new_value
    end
    status.save!

    # 上限値下限値要設定(大事なものについても)
    # (effects["items"] || []).each do |e|
    # item  = current_user.user_items.find_or_initialize_by(code: e["item_code"])
    # delta = e["delta"].to_i
    # item.count = item.count.to_i + delta
    # item.save!
    # end
  end

  def apply_automatic_decay!(play_state)
    status    = current_user.user_status
    now       = Time.current
    last_time = play_state.updated_at
    elapsed   = now - last_time

    hunger_ticks = (elapsed / 15.minutes).floor
    status.hunger_value -= hunger_ticks if hunger_ticks > 0

    love_ticks = (elapsed / 8.hours).floor
    status.love_value -= love_ticks * 18 if love_ticks > 0

    status.hunger_value  = [ [ status.hunger_value, 0 ].max, 100 ].min
    status.love_value    = [ [ status.love_value,   0 ].max, 100 ].min

    status.save!

    play_state.touch
  end
end
