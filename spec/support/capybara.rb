# spec/support/capybara.rb
require 'capybara/rails'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  # 必要最小限の引数だけ
  %w[headless disable-gpu no-sandbox disable-dev-shm-usage].each do |flag|
    options.add_argument("--#{flag}")
  end

  # ドライバ自動検出に任せる（chromedriver・chromeのパスを個別指定しない）
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# JS テスト時のドライバとして使う
Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 5
