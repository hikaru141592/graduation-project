# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'
require 'capybara/rspec'
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  # テスト DB のスキーマを最新化
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include AuthenticationMacros, type: :system
  config.include AuthenticationMacros, type: :request

  # seeds.rb を 1 度だけ読み込む
  config.before(:suite) do
    Rails.application.load_seed
  end

  # System テストは headless_chrome を使用
  config.before(type: :system) do
    driven_by :headless_chrome
  end

  config.before(:each, type: :system) do
    puts "EventSet 件数 = #{EventSet.count}"
    PlayState.delete_all
    UserStatus.delete_all
  end
end
