require "database_cleaner/active_record"
DatabaseCleaner.allow_remote_database_url = true

SEED_TABLES = %w[
  event_categories
  event_sets
  events
  action_choices
  action_results
  cuts
].freeze

RSpec.configure do |config|
  config.before(:suite) do
    abort "Wrong database!" unless Rails.env.test?
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end

  config.before(:each) do |ex|
    if ex.metadata[:type] == :system
      DatabaseCleaner.strategy = :truncation,
                                { only: %w[play_states user_statuses] }
    else
      DatabaseCleaner.strategy = :truncation,
                                { except: SEED_TABLES }
    end
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
