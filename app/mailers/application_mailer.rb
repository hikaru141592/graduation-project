class ApplicationMailer < ActionMailer::Base
  default from: (
    Rails.env.production? ? ENV.fetch("MAILGUN_SMTP_LOGIN") : "from@example.com"
  )
  layout "mailer"
end
