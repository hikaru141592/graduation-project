class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      user.send(:clear_reset_password_token)
      user.save!
      user.deliver_reset_password_instructions!
      # user.send(:set_reset_password_token)
      # user.save!
      # UserMailer.reset_password_email(user).deliver_now
    end
    redirect_to password_resets_create_path, success: t("flash.password_resets.create.success")
  end

  def create_page
  end

  def edit
    @token = params[:token].to_s
    @user = User.load_from_reset_password_token(@token)
    if @user.nil?
      flash[:danger] = t("flash.password_resets.edit.danger")
      redirect_to new_password_reset_path
    end
  end

  def update
    @token = params[:token].to_s
    @user = User.load_from_reset_password_token(@token)
    if @user.nil?
      flash[:danger] = t("flash.password_resets.update.invalid_token.danger")
      redirect_to new_password_reset_path and return
    end

    password = params[:user][:password].to_s
    password_confirmation = params[:user][:password_confirmation].to_s
    if password != password_confirmation
      flash.now[:danger] = t("flash.password_resets.update.password_mismatch.danger")
      render :edit, status: :unprocessable_entity and return
    end

    @user.password_confirmation = password_confirmation
    if @user.change_password!(password)
      redirect_to complete_update_password_reset_path, success: t("flash.password_resets.update.success")
    else
      flash.now[:danger] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def complete_update
  end
end
