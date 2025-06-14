class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :redirect_if_incomplete_profile
  add_flash_types :success, :danger

  private

  def not_authenticated
    redirect_to login_path, danger: "ログインが必要です。"
  end

  def redirect_if_incomplete_profile
    if session[:user_id] && current_user.nil?
      reset_session
      return redirect_to login_path, danger: 'セッションが切れています。再度ログインしてください。'
    end
    return unless current_user
    return if request.path == login_path
    return if current_user.profile_completed?
    return if request.path == complete_profile_path
    redirect_to complete_profile_path
  end
end
