module StatusHelper
  def study_evaluate(value, effort_value = 0)
    evaluate_value = (value + effort_value * 0.3).to_i
    case evaluate_value
    when 0..2     then "ふつう"
    when 3..6    then "ちょっといいかんじかも"
    when 7..12   then "ちょっといいかんじ"
    when 13..20   then "そこそこできる"
    when 21..35   then "すごくできる"
    when 36..60   then "できすぎ！"
    when 61..100   then "てんさい？"
    when 101..200  then "てんさい！"
    when 201..400 then "てんさいすぎ！"
    else                "かみさま"
    end
  end

  def vitality_point(temp, max)
    temp_point = (temp / VITALITY_UNIT).to_i
    max_point = (max / VITALITY_UNIT).to_i
    "#{temp_point} / #{max_point}"
  end
end
