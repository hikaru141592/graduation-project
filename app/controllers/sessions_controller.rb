class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    @user = login(params[:email], params[:password])
    if @user
      redirect_to root_path, success: "ログインに成功しました。"
    else
      flash.now[:alert] = "メールアドレスかパスワードが違います。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "ログアウトしました。", status: :see_other
  end
end
