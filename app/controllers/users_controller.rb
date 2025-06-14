class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create complete_profile update_profile]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, success: "登録が完了しました。ログインしてください。"
    else
      flash.now[:danger] = "入力に誤りがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  def complete_profile
    @user = User.find(session[:user_id])
    #flash.now[:name] = session[:pending_oauth]['name']

    if @user.profile_completed?
      redirect_to root_path, danger: 'そのページにはアクセスできません'
      return
    end
  end

  def update_profile
    @user = User.find(session[:user_id])
    if @user.update(profile_params)
      auto_login(@user)
      redirect_to root_path, success: "プロフィールを登録しました。"
    else
      flash.now[:danger] = "入力に誤りがあります。"
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
