FactoryBot.define do
  factory :event_temporary_datum do
    user { nil }
    reception_count { 1 }
    success_count { 1 }
    started_at { "2025-07-06 15:20:01" }
  end
end
