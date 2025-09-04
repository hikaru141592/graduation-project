Rails.application.config.sorcery.submodules = [ :activity_logging, :reset_password, :external, :remember_me ]
Rails.application.config.sorcery.configure do |config|
  config.user_config do |user|
    user.stretches = 1 if Rails.env.test?
    user.reset_password_mailer = UserMailer
    user.authentications_class = Authentication
  end

  config.user_class = "User"

  config.external_providers = [ :line ]
  config.line.key          = ENV["LINE_KEY"]
  config.line.secret       = ENV["LINE_SECRET"]
  if Rails.env.development?
    config.line.callback_url = "https://2f5116df914d.ngrok-free.app/auth/line/callback"
  elsif Rails.env.production?
    config.line.callback_url = "https://www.tamago-wakuwaku.com/auth/line/callback"
  end
  config.line.scope        = "profile openid email"
  config.line.user_info_mapping = { name: "displayName", email: "email" }
  config.line.bot_prompt = "aggressive"
end
