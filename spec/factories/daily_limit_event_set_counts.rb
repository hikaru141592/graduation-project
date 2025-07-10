FactoryBot.define do
  factory :daily_limit_event_set_count do
    user { nil }
    event_set { nil }
    occurred_on { "2025-07-09" }
    count { 1 }
  end
end
