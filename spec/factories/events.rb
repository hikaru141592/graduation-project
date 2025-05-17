FactoryBot.define do
  factory :event do
    association :event_set
    name { "テストイベント" }
    derivation_number { 0 }
    message { "こんにちは！" }
    character_image { "char.png" }
    background_image { "bg.png" }
  end
end
