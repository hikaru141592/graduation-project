class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, success: t("flash.users.create.success")
    else
      flash.now[:danger] = t("flash.users.create.danger")
      render :new, status: :unprocessable_entity
    end
  end

  def complete_profile
    @user = User.find(session[:user_id])

    if @user.profile_completed?
      auto_login(@user)
      redirect_to root_path
    end
  end

  def update_profile
    @user = User.find(session[:user_id])
    if @user.update(profile_params)
      auto_login(@user)
      remember_me! if session.delete(:remember_flag) == "1"
      redirect_to root_path
    else
      flash.now[:danger] = t("flash.users.update_profile.danger")
      render :complete_profile, status: :unprocessable_entity
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

  def profile_params
    params.require(:user).permit(
      :name,
      :egg_name,
      :birth_month,
      :birth_day,
    )
  end
end
