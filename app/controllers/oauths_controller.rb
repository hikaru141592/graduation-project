class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false

  def line_login
    session[:remember] = params[:remember]
    redirect_to "/auth/line"
  end

  def callback
    auth_hash      = request.env["omniauth.auth"]
    access_token   = auth_hash.dig("credentials", "token")
    authentication = Authentication.find_by(
      provider: auth_hash.provider,
      uid:      auth_hash.uid
    )
    @user = if authentication
      authentication.user
    else
      user = pro_user_registration(auth_hash)
      user
    end

    update_line_friend_status(@user, access_token)

    remember_flag = session.delete(:remember)
    reset_session

    if @user.profile_completed?
      auto_login(@user)
      remember_me! if remember_flag == "1"
      redirect_to root_path, success: "ログインに成功しました。"
    else
      # requireログインには引っかかるよう、auto_loginは使用しない
      # remember_me!はプロフィール補完完了後に行う
      session[:user_id] = @user.id
      session[:remember_flag] = remember_flag
      redirect_to complete_profile_path
    end
  end

  private
  def pro_user_registration(auth_hash)
    # OmniAuthの標準キーnameとLINE仕様のキーdisplayNameいずれにも念のため対応
    raw_name       = (auth_hash.dig("info", "name").presence || auth_hash.dig("info", "displayName").presence)
    truncated_name = raw_name.each_char.take(User::NAME_MAX_LENGTH).join

    # LINE認証ではパスワードリセットが不要なため、emailは取得せずダミー値を格納
    # egg_name、birth_month、birth_dayは一時的にダミーとして「未登録」とし、このあとユーザーのフォーム入力で正式決定
    user = User.new(
      email:       "temp-#{SecureRandom.uuid}@example.com",
      name:        truncated_name,
      egg_name:    "未登録",
      birth_month: 1,
      birth_day:   1
    )

    # 現状フレンド機能は未実装だが、今後実装の可能性があるためフレンドコードを割り振る
    user.send(:assign_friend_code)

    dummy_pw = SecureRandom.urlsafe_base64(12)
    user.password              = dummy_pw
    user.password_confirmation = dummy_pw

    # Sorceryがsave!時に自動で呼び出すため、明示呼び出しは削除
    # user.send(:encrypt_password)

    # 未登録というegg_nameは本来バリデーションではじかれるがここでは無視する。
    user.save!(validate: false)
    Authentication.create!(user: user, provider: auth_hash.provider, uid: auth_hash.uid)

    user
  end

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
