require 'capybara/rails'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  %w[headless disable-gpu no-sandbox disable-dev-shm-usage].each do |flag|
    options.add_argument("--#{flag}")
  end

  # SeleniumとChromeは自動で探す
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# JSテスト時のドライバ用
Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 5
