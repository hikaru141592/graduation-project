class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = user
    @url = edit_password_reset_url(token: @user.reset_password_token)
    mail(to: @user.email, subject: "パスワード再発行のご案内")
  end
end
