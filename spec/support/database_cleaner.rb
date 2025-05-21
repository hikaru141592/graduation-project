require "database_cleaner/active_record"
DatabaseCleaner.allow_remote_database_url = true

# テスト DB に残したい「シード用テーブル」
SEED_TABLES = %w[
  event_categories
  event_sets
  events
  action_choices
  action_results
  cuts
].freeze

RSpec.configure do |config|
  # --- スイート開始時 -------------------------------------------------
  config.before(:suite) do
    abort "Wrong database!" unless Rails.env.test?
    DatabaseCleaner.clean_with(:truncation)   # 一旦まっさらに
    Rails.application.load_seed              # その後 seed を投入
  end

  # --- example 前 -----------------------------------------------------
  config.before(:each) do |ex|
    if ex.metadata[:type] == :system
      # System テストはユーザの進行状況だけ消せば十分
      DatabaseCleaner.strategy = :truncation,
                                { only: %w[play_states user_statuses] }
    else
      # それ以外は seed テーブルを除いて TRUNCATE
      DatabaseCleaner.strategy = :truncation,
                                { except: SEED_TABLES }
    end
    DatabaseCleaner.start
  end

  # --- example 後 -----------------------------------------------------
  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
