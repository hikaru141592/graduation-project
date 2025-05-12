require "capybara/rails"
require "selenium/webdriver"
require "tmpdir"

Capybara.register_driver :headless_chrome do |app|
  chrome_bin    = "/usr/bin/chromium"
  driver_bin    = "/usr/bin/chromedriver"
  # 一意のプロファイルディレクトリを毎回作成
  user_data_dir = Dir.mktmpdir("chrome-user-data")

  service = Selenium::WebDriver::Service.chrome(path: driver_bin)

  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = chrome_bin
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--user-data-dir=#{user_data_dir}")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    service: service,
    options: options
  )
end

# JS テスト時のドライバとして使う
Capybara.javascript_driver    = :headless_chrome
Capybara.default_max_wait_time = 5
