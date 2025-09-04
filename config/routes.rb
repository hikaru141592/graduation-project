Rails.application.routes.draw do
  # ----- サインアップ/通常ログイン -----
  resources :users, only: [ :new, :create ]
  resource :session, only: [ :new, :create, :destroy ]

  # ----- ログイン後 -----
  resource :game, only: [], controller: "games" do
    post :select_action
    post :advance_cut
  end
  root to: "games#play"

  resource :settings, only: [ :show ]
  namespace :settings do
    resource :line_notification, only: [ :show, :update ]
    resource :account, only: [ :show, :destroy ], path: "delete_account", as: "delete_account"
  end

  resource :status, only: [ :show ], controller: "status"

  # ----- 静的ページ -----
  controller :public_pages do
    get :privacy_policy, action: :privacy
    get :term
    get :about
  end

  # ----- パスワードリセット -----
  resources :password_resets, param: :token, only: [ :new, :create, :edit, :update ] do
    collection do
      get :create_page
      get :complete_update
    end
  end

  # ----- LINE関係 -----
  get "/line_login", to: "oauths#line_login", as: "line_login"
  match "/auth/:provider/callback", to: "oauths#callback", via: %i[get post]
  get "/auth/failure",            to: redirect("/")

  resource :profile_completion, only: [ :edit, :update ]

  post "/webhooks/line", to: "line_webhooks#callback"

  # ----- 開発用 -----
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
