FactoryBot.define do
  factory :user_event_category_invalidation do
    association :user
    association :event_category
    expires_at { "2025-06-28 17:05:27" }
  end
end
