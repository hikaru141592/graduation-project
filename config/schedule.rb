env :PATH,        ENV["PATH"]
env :TZ,          "Asia/Tokyo"
env :BUNDLE_GEMFILE, "/app/Gemfile"
env :GEM_PATH,    "/usr/local/lib/ruby/gems/3.2.0"
set :output,      "log/cron.log"
set :environment, "development"

# every '28 16 17 7 *' do
every 1.minute do
  runner "SeasonalNotificationJob.perform_now"
end
