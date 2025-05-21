FactoryBot.define do
  factory :event_category do
    sequence(:name) { |n| "カテゴリ#{n}" }
    loop_minutes    { nil }
  end
end
