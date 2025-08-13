class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false
  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  # def oauth
  #   login_at(auth_params[:provider])
  # end

  def line_login
    session[:remember] = params[:remember]
    redirect_to "/auth/line"
  end

  def callback
    auth_hash = request.env["omniauth.auth"]
    Rails.logger.debug "=== AUTH HASH ===\n#{auth_hash.to_h.inspect}\n================="
    access_token = auth_hash.dig("credentials", "token")
    Rails.logger.debug "LINE access_token present? #{access_token.present?}"
    
    # 後程リファクタリング：raw_name = (auth_hash.dig("info", "name").presence || auth_hash.dig("info", "displayName").presence)
    raw_name = auth_hash.info.name.to_s.presence || auth_hash.info["displayName"].to_s
    truncated_name = raw_name.each_char.take(6).join
    authentication = Authentication.find_by(
      provider: auth_hash.provider,
      uid:      auth_hash.uid
    )
    @user = if authentication
      authentication.user
    else

      user = User.new(
        email:       auth_hash.info["email"].presence || "temp-#{SecureRandom.uuid}@example.com",
        name:        truncated_name,
        egg_name:    "未登録",
        birth_month: 1,
        birth_day:   1
      )
      user.send(:assign_friend_code)
      dummy_pw = SecureRandom.urlsafe_base64(12)
      user.password              = dummy_pw
      user.password_confirmation = dummy_pw
      user.send(:encrypt_password)
      # 未登録というegg_nameは本来バリデーションではじかれるがここでは無視する。
      user.save!(validate: false)
      Authentication.create!(user: user, provider: auth_hash.provider, uid: auth_hash.uid)
      user
    end

    update_line_friend_status(@user, access_token)
    
    remember_flag = session.delete(:remember)
    reset_session
    session[:user_id] = @user.id
    # session[:pending_oauth]はおそらく不要
    session[:pending_oauth] = {
      provider: auth_hash.provider,
      uid:      auth_hash.uid,
      name:     truncated_name,
      email:    auth_hash.info["email"]
    }

    if @user.profile_completed?
      auto_login(@user)
      remember_me! if remember_flag == "1"
      redirect_to root_path, success: "ログインに成功しました。"
    else
      redirect_to complete_profile_path
    end
  end

  private
  def auth_params
    params.permit(:provider)
  end

  def update_line_friend_status(user, access_token)
    return if access_token.blank?
    begin
      friend_flag = fetch_line_friend_flag(access_token)
      user.update_column(:line_friend_linked, friend_flag)
    rescue => e
      Rails.logger.warn("[LINE Friendship] #{e.class}: #{e.message}")
    end
  end

  def fetch_line_friend_flag(access_token)
    require "net/http"
    require "json"

    uri  = URI("https://api.line.me/friendship/v1/status")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{access_token}"

    res = http.request(req)
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)["friendFlag"]
  end
end
