class MessageBuilder
  def initialize(play_state, question_text)
    @play_state = play_state
    @user       = play_state.user
    @question_text = question_text
    @current_event = play_state.current_event
  end

  def call
    message = @play_state.current_cut&.random_message(@play_state.updated_at) || @current_event.message
    message = replace_question_text(message)
    message = replace_egg_name(message)
    message = replace_user_name(message)
    message = replace_training_report(message)
  end

  private

  def replace_question_text(message)
    return message unless @question_text.present?
    message.gsub("X 演算子 Y", @question_text)
  end

  def replace_egg_name(message)
    message.gsub("〈たまご〉", @user.egg_name_with_suffix)
  end

  def replace_user_name(message)
    message.gsub("〈ユーザー〉", @user.name)
  end

  def replace_training_report(message)
    return message unless @current_event.event_set.name == "特訓" && (2..6).include?(@current_event.derivation_number)
    temp = @user.event_temporary_datum
    success_count = temp.success_count
    message = message.gsub("〈X〉", success_count.to_s)
    elapsed_sec = (temp.ended_at - temp.started_at).to_i
    minutes, seconds = elapsed_sec.divmod(60)
    time_str    = "#{minutes}ふん #{seconds}びょう"
    message     = message.gsub("〈Y〉ふん 〈Z〉びょう", time_str)
  end
end
