FactoryBot.define do
  factory :action_choice do
    association :event
    position { 1 }
    label    { "テストラベル" }
  end
end
