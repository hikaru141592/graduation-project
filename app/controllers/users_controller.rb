class UsersController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to new_session_path, success: t("flash.users.create.success")
    else
      flash.now[:danger] = t("flash.users.create.danger")
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
