FactoryBot.define do
  factory :user_status do
    association :user

    hunger_value    { 50 }
    happiness_value { 10 }
    love_value      { 0 }
    mood_value      { 0 }
    study_value     { 0 }
    sports_value    { 0 }
    art_value       { 0 }
    money           { 0 }

    current_loop_event_set { nil }
    current_loop_started_at { nil }
  end
end
