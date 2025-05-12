class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, success: "登録が完了しました。ログインしてください。"
    else
      flash.now[:alert] = "入力に誤りがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :name,
      :egg_name,
      :birth_month,
      :birth_day,
    )
  end
end
