class Settings::LineNotificationsController < ApplicationController
  before_action :ensure_line_login_authenticated, only: %i[show update]

  def show
    @user= current_user
  end

  def update
    @user= current_user
    if @user.update(user_params)
      redirect_to settings_line_notification_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def ensure_line_login_authenticated
    unless current_user.authentications.exists?(provider: "line")
      redirect_to settings_path
    end
  end

  def user_params
    params.require(:user).permit(:line_notifications_enabled)
  end
end
