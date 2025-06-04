Rails.application.config.sorcery.submodules = [ :activity_logging, :reset_password ]
Rails.application.config.sorcery.configure do |config|
  config.user_config do |user|
    user.stretches = 1 if Rails.env.test?
    user.reset_password_mailer = UserMailer
  end

  config.user_class = "User"
end
