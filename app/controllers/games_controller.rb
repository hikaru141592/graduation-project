class GamesController < ApplicationController
  require "time"

  def play
    @play_state = current_user.play_state
    @user_status = current_user.user_status
    # ステータス減少が適切に行われなくなるため@play_state.touchはしない
    # @play_state.apply_automatic_update!はしない
    EventTimeout.new(@play_state, @user_status, request.headers).handle_timeouts

    @event = @play_state.current_event
    if @play_state.current_cut_position.present?
      choice = @event.action_choices.find_by!(position: @play_state.action_choices_position)
      @action_result = choice.action_results.find_by!(priority: @play_state.action_results_priority)
      @cut = @action_result.cuts.find_by!(position: @play_state.current_cut_position)
      @phase = :cut
    else
      @choices = @event.action_choices.order(:position)
      @phase = :select
      if @event.event_set.name == "算数" && (1..4).include?(@event.derivation_number)
        seed = @play_state.updated_at.to_i
        @question_text, @options = ArithmeticQuiz.generate(seed: seed)
      end
      @temp = current_user.event_temporary_datum
    end

    set_base_background_image
  end

  def select_action
    play_state = current_user.play_state
    unless Rails.env.test?
      client_ts = Time.iso8601(params.require(:state_timestamp))
      if client_ts.to_i < play_state.updated_at.to_i
        redirect_to root_path and return
      end
    end
    play_state.apply_automatic_update!

    event = play_state.current_event
    position = params.require(:position).to_i
    choice = event.action_choices.find_by!(position: position)
    result = choice.action_results.order(:priority).detect { |ar| conditions_met?(ar.trigger_conditions, current_user) }
    result ||= choice.action_results.order(priority: :desc).first

    if result.cuts.exists?
      play_state.update!(action_choices_position: position, action_results_priority: result.priority, current_cut_position: 1)
      redirect_to root_path and return
    else
      play_state.update!(action_choices_position: position, action_results_priority: result.priority, current_cut_position: nil)
      advance_cut(skip_check: true)
    end
  end

  def advance_cut(skip_check: false)
    play_state = current_user.play_state

    # select_actionでカット数0で呼び出された場合にタイムスタンプチェックをスキップする。
    unless skip_check || Rails.env.test?
      client_ts = Time.iso8601(params.require(:state_timestamp))
      if client_ts.to_i < play_state.updated_at.to_i
        redirect_to root_path and return
      end
    end

    current = play_state.current_cut_position.to_i
    next_cut = current + 1
    event   = play_state.current_event
    choice  = event.action_choices.find_by!(position: play_state.action_choices_position)
    result  = choice.action_results.find_by!(priority: play_state.action_results_priority)

    if result.cuts.exists?(position: next_cut)
      play_state.apply_automatic_update!
      play_state.update!(current_cut_position: next_cut)
    else
      apply_effects!(result.effects)
      play_state.apply_automatic_update!

      user_status = current_user.user_status
      current_set = event.event_set
      resolves = result.resolves_loop?

      current_user.clear_event_category_invalidations!

      if result.next_derivation_number.present?
        next_set, next_event = apply_derivation(result)
      else
        if resolves
          event_category_invalidation(current_user, current_set.event_category, 2.hours.from_now)
        end
        if continue_loop?(user_status, current_set, resolves)
          next_set = current_set
          next_event = event
        else
          user_status.clear_loop_status!
          next_set, next_event = current_user.pick_next_event_set_and_event
          next_set, next_event = apply_event_set_call(result, next_set, next_event)
          next_set, next_event = apply_event_set_call(result, next_set, next_event)
          user_status.record_loop_start!
        end
      end

      arithmetic_training_event_processor = ArithmeticTrainingEventProcessor.new(current_user, result, next_set, next_event)
      next_set, next_event = arithmetic_training_event_processor.call
      arithmetic_training_event_processor.record_evaluation

      ball_training_event_processor = BallTrainingEventProcessor.new(current_user, result, next_set, next_event)
      next_set, next_event = ball_training_event_processor.call
      ball_training_event_processor.record_evaluation

      play_state.start_new_event!(next_event)
    end

    redirect_to root_path
  end

  private

  # モデル移動可
  def conditions_met?(conds, user)
    return true if conds["always"] == true
    op   = conds["operator"] || "and"
    list = conds["conditions"] || []
    results = list.map do |c|
      case c["type"]
      when "status"
        user.user_status.send(c["attribute"]).public_send(c["operator"], c["value"])
      when "probability"
        rand(100) < c["percent"]
      when "item"
        user.user_items.find_by(code: c["item_code"]).try(:count).to_i.public_send(c["operator"], c["value"])
      when "event_temporary_data"
        user.event_temporary_datum.send(c["attribute"]).public_send(c["operator"], c["value"])
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

  def continue_loop?(user_status, event_set, resolves_loop)
    return false if resolves_loop
    user_status.in_loop?
  end

  def event_category_invalidation(user, event_category, expires_at)
    inv = user.user_event_category_invalidations.find_or_initialize_by(event_category: event_category)
    inv.expires_at = expires_at
    inv.save!
  end

  def apply_event_set_call(action_result, default_set, default_event)
    if action_result.calls_event_set_id.present?
      event_set = EventSet.find(action_result.calls_event_set_id)
      event = event_set.events.find_by!(derivation_number: 0)
      [ event_set, event ]
    else
      [ default_set, default_event ]
    end
  end

  def apply_derivation(result)
    derivation_num = result.next_derivation_number
    event_set = result.action_choice.event.event_set
    begin
      derived_event = event_set.events.find_by!(derivation_number: derivation_num)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Derivation event not found: set=#{event_set.id}, num=#{derivation_num}"
      derived_event = event_set.events.find_by!(derivation_number: 0)
    end
    [ event_set, derived_event ]
  end

  def set_base_background_image
    current_hour = Time.zone.now.hour
    @base_background_image =
      case current_hour
      when 6...17
        "temp-base_background/temp-base_background1.png"
      when 17...18
        "temp-base_background/temp-base_background2.png"
      else
        "temp-base_background/temp-base_background3.png"
      end
  end
end
