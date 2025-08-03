class DeleteAccountController < ApplicationController
  skip_after_action :register_last_activity_time_to_db, only: :destroy

  def show
  end

  def destroy
    current_user.destroy!
    reset_session
    redirect_to login_path, danger: "アカウントを削除しました。", status: :see_other
  end
end
