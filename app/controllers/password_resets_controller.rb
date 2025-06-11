class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      #user.deliver_reset_password_instructions!
      user.send(:set_reset_password_token)
      user.save!
      UserMailer.reset_password_email(user).deliver_now
    end
    redirect_to password_resets_create_path, success: t("password_resets.create.success", default: "パスワードリセット手順を送信しました")
  end

  def create_page
  end

  def edit
    @token = params[:token].to_s
    @user = User.load_from_reset_password_token(@token)
    if @user.nil?
      flash[:alert] = t("password_resets.edit.invalid_token", default: "リンクが無効か、有効期限が切れています。再度お試しください。")
      redirect_to new_password_reset_path
    end
  end

  def update
    @token = params[:token].to_s
    @user = User.load_from_reset_password_token(@token)
    if @user.nil?
      flash[:alert] = t("password_resets.edit.invalid_token", default: "リンクが無効か、有効期限が切れています。再度お試しください。")
      redirect_to new_password_reset_path and return
    end

    password = params[:user][:password].to_s
    password_confirmation = params[:user][:password_confirmation].to_s
    if password != password_confirmation
      flash.now[:alert] = t("password_resets.update.password_mismatch", default: "パスワードと確認用パスワードが一致しません。")
      render :edit, status: :unprocessable_entity and return
    end

    @user.password_confirmation = password_confirmation
    if @user.change_password!(password)
      redirect_to complete_update_password_reset_path, success: t("password_resets.update.success", default: "パスワードを変更しました。")
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def complete_update
  end
end
