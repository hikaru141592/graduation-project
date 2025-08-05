FactoryBot.define do
  factory :user_status do
    association :user

    hunger_value    { 50 }
    happiness_value { 10 }
    love_value      { 50 }
    mood_value      { 0 }
    sports_value    { 0 }
    art_value       { 0 }
    money           { 0 }
    arithmetic      { 0 }
    arithmetic_effort { 0 }
    japanese        { 0 }
    japanese_effort { 0 }
    science         { 0 }
    science_effort  { 0 }
    social_studies  { 0 }
    social_effort   { 0 }

    current_loop_event_set { nil }
    current_loop_started_at { nil }
  end
end
