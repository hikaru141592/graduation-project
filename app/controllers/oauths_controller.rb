class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false
  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  # def oauth
  #   login_at(auth_params[:provider])
  # end

  def callback
    auth_hash = request.env['omniauth.auth']
    Rails.logger.debug "=== AUTH HASH ===\n#{auth_hash.to_h.inspect}\n================="
    raw_name = auth_hash.info.name.to_s.presence || auth_hash.info['displayName'].to_s
    truncated_name = raw_name.each_char.take(6).join
    authentication = Authentication.find_by(
      provider: auth_hash.provider,
      uid:      auth_hash.uid
    )
    @user = if authentication
      authentication.user
    else

      user = User.new(
        email:       auth_hash.info['email'].presence || "temp-#{SecureRandom.uuid}@example.com",
        name:        truncated_name,
        egg_name:    '未登録',
        birth_month: 1,
        birth_day:   1
      )
      user.send(:assign_friend_code)
      dummy_pw = SecureRandom.urlsafe_base64(12)
      user.password              = dummy_pw
      user.password_confirmation = dummy_pw
      user.send(:encrypt_password)      # ここで明示的に crypted_password と salt を生成
      # 未登録というegg_nameは本来バリデーションではじかれるがここでは無視する。
      user.save!(validate: false)
      Authentication.create!(user: user, provider: auth_hash.provider, uid: auth_hash.uid)
      user
    end
    reset_session
    session[:user_id] = @user.id
    session[:pending_oauth] = {
      provider: auth_hash.provider,
      uid:      auth_hash.uid,
      name:     truncated_name,
      email:    auth_hash.info['email']
    }

    redirect_to complete_profile_path and return

    auto_login(@user)
    redirect_to root_path, success: "ログインに成功しました。"
  end

  private def auth_params
    params.permit(:provider)
  end

end
