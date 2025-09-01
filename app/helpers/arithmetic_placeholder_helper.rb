module ArithmeticPlaceholderHelper
  def arithmetic_option_replace(original_option_text, arithmetic_question_text, arithmetic_options)
    return original_option_text if arithmetic_question_text.blank?
    arithmetic_options.each_with_index do |opt, idx|
      placeholder = "〈#{('A'.ord + idx).chr}〉"
      original_option_text.gsub!(placeholder, opt.to_s)
    end

    original_option_text
  end
end
