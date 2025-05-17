FactoryBot.define do
  factory :play_state do
    association :user
    association :current_event, factory: :event

    action_choices_position  { nil }
    action_results_priority  { nil }
    current_cut_position     { nil }
  end
end
