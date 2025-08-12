module StatusHelper
  def study_evaluate(value, effort_value = 0)
    evaluate_value = (value + effort_value * 0.3).to_i
    case evaluate_value
    when 0..5     then "ふつう"
    when 6..10    then "ちょっといいかんじかも"
    when 11..20   then "ちょっといいかんじ"
    when 20..35   then "そこそこできる"
    when 35..50   then "すごくできる"
    when 51..80   then "できすぎ！"
    when 81..120   then "てんさい？"
    when 121..250  then "てんさい！"
    when 251..450 then "てんさいすぎ！"
    else                "かみさま"
    end
  end

  def vitality_point(temp, max)
    temp_point = (temp / VITALITY_UNIT).to_i
    max_point = (max / VITALITY_UNIT).to_i
    "#{temp_point} / #{max_point}"
  end
end
