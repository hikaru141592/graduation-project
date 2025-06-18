class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    Rails.logger.debug "🛠️  params[:remember]=#{params[:remember].inspect}"
    if login(params[:email], params[:password], params[:remember] == "1")
      @user = current_user
      redirect_to root_path, success: "ログインに成功しました。"
    else
      flash.now[:danger] = "メールアドレスかパスワードが違います。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget_me!
    logout
    redirect_to login_path, danger: "ログアウトしました。", status: :see_other
  end
end
