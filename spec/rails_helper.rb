require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'
require 'capybara/rspec'
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts "⚙️ Pending migrations detected. Running db:migrate for test environment..."
  system('RAILS_ENV=test bin/rails db:migrate')
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e2
    abort e2.to_s.strip
  end
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include AuthenticationMacros, type: :system
  config.include AuthenticationMacros, type: :request

  config.before(:suite) do
    Rails.application.load_seed
  end

  config.before(type: :system) do
    driven_by :headless_chrome
  end

  config.before(:each, type: :system) do
    puts "EventSet 件数 = #{EventSet.count}"
    PlayState.delete_all
    UserStatus.delete_all
  end

  config.before(:each, type: :job) do
    ActiveJob::Base.queue_adapter = :test
  end
end
