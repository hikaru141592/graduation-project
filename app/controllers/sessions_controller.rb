class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    redirect_to root_path if current_user.present?
  end

  def create
    Rails.logger.debug "🛠️  params[:remember]=#{params[:remember].inspect}"
    if login(params[:email], params[:password], params[:remember] == "1")
      @user = current_user
      redirect_to root_path, success: t("flash.sessions.create.success")
    else
      flash.now[:danger] = t("flash.sessions.create.danger")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget_me!
    logout
    redirect_to login_path, danger: t("flash.sessions.destroy.danger"), status: :see_other
  end
end
