Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line,
    ENV["LINE_KEY"],
    ENV["LINE_SECRET"],
    scope: "profile openid",
    bot_prompt: "aggressive",
    callback_path: "/auth/line/callback"
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
