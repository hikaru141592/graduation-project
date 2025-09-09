FactoryBot.define do
  factory :play_state do
    association :user
    association :current_event
  end
end
