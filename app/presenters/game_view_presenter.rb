class GameViewPresenter
  attr_reader :play_state, :event

  def initialize(play_state)
    @play_state = play_state
    @event      = play_state.current_event
  end

  def phase
    after_select_phase? ? :after_select : :select_now
  end

  # choice、action_result、cutメソッドの3つはafter_select_phase用
  def choice
    return unless after_select_phase?
    play_state.current_choice
  end

  def action_result
    return unless after_select_phase?
    play_state.current_action_result
  end

  def cut
    return unless after_select_phase?
    play_state.current_cut
  end

  # choices、arithmetic_question_text、arithmetic_optionsメソッドの3つはselect_now_phase用
  def choices
    return unless select_now_phase?
    event.ordered_action_choices
  end

  def arithmetic_question_text
    arithmetic_payload&.first
  end

  def arithmetic_options
    arithmetic_payload&.last
  end

  # いずれのphaseでも使用
  def base_background_image
    case Time.current.hour
    when 6...17
      "temp-base_background/temp-base_background1.png"
    when 17...18
      "temp-base_background/temp-base_background2.png"
    else
      "temp-base_background/temp-base_background3.png"
    end
  end

  private

  def after_select_phase?
    play_state.current_cut_position.present?
  end

  def select_now_phase?
    !after_select_phase?
  end

  def arithmetic_payload
    return unless select_now_phase? && event.arithmetic_quiz_being_asked?
    @arithmetic_payload ||= ArithmeticQuiz.generate(seed: seed)
  end

  def seed
    play_state.updated_at.to_i
  end
end
