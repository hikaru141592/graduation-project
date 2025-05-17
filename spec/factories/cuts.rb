FactoryBot.define do
  factory :cut do
    association :action_result
    position           { 1 }
    message            { "テスト用のメッセージ" }
    character_image    { "char.png" }
    background_image   { "bg.png" }
  end
end
