# spec/factories/event_sets.rb
FactoryBot.define do
  factory :event_set do
    association :event_category
    name { "テストセット" }
    trigger_conditions { { always: true } }
  end
end
