class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :redirect_if_incomplete_profile
  add_flash_types :success, :danger

  private

  def not_authenticated
    redirect_to new_session_path, danger: t("flash.application.not_authenticated.danger")
  end

  def redirect_if_incomplete_profile
    if session[:user_id] && current_user.nil?
      reset_session
      return redirect_to new_session_path, danger: t("flash.application.redirect_if_incomplete_profile.danger")
    end
    return unless current_user
    return if request.path == new_session_path
    return if current_user.profile_completed?
    return if request.path == complete_profile_path
    redirect_to complete_profile_path
  end
end
