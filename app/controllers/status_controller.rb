class StatusController < ApplicationController
  def show
    @user        = current_user
    @user_status = current_user.user_status
    render partial: 'status/status', locals: { user: @user, user_status: @user_status }
  end
end
