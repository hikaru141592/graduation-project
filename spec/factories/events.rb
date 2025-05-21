FactoryBot.define do
  factory :event do
    association :event_set
    sequence(:name) { |n| "イベント#{n}" }
    derivation_number { 0 }
    message           { "テストイベントです" }
    character_image   { "character/kari-normal.png" }
    background_image  { "background/kari-background.png" }
  end
end