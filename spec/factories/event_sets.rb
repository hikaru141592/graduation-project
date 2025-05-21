# spec/factories/event_sets.rb
FactoryBot.define do
  factory :event_set do
    association :event_category
    sequence(:name) { |n| "イベントセット#{n}" }
    trigger_conditions { { always: true } }
  end
end
