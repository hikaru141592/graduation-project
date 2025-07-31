module StatusHelper
  def study_evaluate(value, effort_value = 0)
    evaluate_value = (value + effort_value * 0.3).to_i
    case evaluate_value
    when 0..5     then 'ふつう'
    when 6..10    then 'ちょっといいかんじかも'
    when 11..15   then 'ちょっといいかんじ'
    when 16..25   then 'そこそこできる'
    when 26..40   then 'すごくできる'
    when 41..60   then 'できすぎ！'
    when 61..90   then 'てんさい？'
    when 91..150  then 'てんさい！'
    when 151..250 then 'てんさいすぎ！'
    else                'かみさま'
    end
  end

  def vitality_point(temp, max)
    temp_point = (temp / 30).to_i
    max_point = (max / 30).to_i
    "#{temp_point} / #{max_point}"
  end
end