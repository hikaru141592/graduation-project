FactoryBot.define do
  factory :action_result do
    association :action_choice
    priority           { 1 }
    trigger_conditions { { always: true } }
    effects            { {} }
    next_derivation_number { nil }
    calls_event_set       { nil }
    resolves_loop         { false }

    trait :with_derivation do
      next_derivation_number { 2 }
      calls_event_set       { nil }
    end

    trait :with_call do
      next_derivation_number { nil }
      association :calls_event_set, factory: :event_set
    end
  end
end
