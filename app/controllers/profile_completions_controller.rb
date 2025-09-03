class ProfileCompletionsController < ApplicationController

  def edit
    @user = User.find(session[:user_id])

    if @user.profile_completed?
      auto_login(@user)
      redirect_to root_path
    end
  end

  def update
    @user = User.find(session[:user_id])
    if @user.update(profile_params)
      auto_login(@user)
      remember_me! if session.delete(:remember_flag) == "1"
      redirect_to root_path
    else
      flash.now[:danger] = t("flash.profile_completions.update.danger")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :name,
      :egg_name,
      :birth_month,
      :birth_day,
    )
  end
end
