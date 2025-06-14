Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line,
    ENV["LINE_KEY"],
    ENV["LINE_SECRET"],
    scope: "profile openid email",
    bot_prompt: "aggressive",
    callback_path: "/auth/line/callback"
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true

# 許可が必要のように思えたが不要だったので削除
# OmniAuth.config.allowed_request_origins = [
#  'https://1e93-126-254-141-126.ngrok-free.app',
#  'http://localhost:3000'
# ]
