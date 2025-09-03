Rails.application.routes.draw do
  resources :users, only: [:new, :create]
  # get  "/users/new", to: "users#new",    as: "new_user"
  # post "/users", to: "users#create"       as: "users"
  # get  "signup", to: "users#new",    as: "signup"   # 元のコード
  # post "signup", to: "users#create"                 # 元のコード

  resource :session, only: [:new, :create, :destroy]
  # get    "/session/new", to: "sessions#new",     as: "new_session" # resourceが展開するルート
  # post   "/session",     to: "sessions#create",  as: "session"     # resourceが展開するルート
  # delete "/session",     to: "sessions#destroy", as: "session"     # resourceが展開するルート
  # get    "login",        to: "sessions#new",     as: "login"       # 元のコード
  # post   "login",        to: "sessions#create"                     # 元のコード
  # delete "logout",       to: "sessions#destroy", as: "logout"      # 元のコード

  resource :game, only: [], controller: "games" do
    post :select_action
    post :advance_cut
  end
  # post "/game/select_action",  to: "games#select_action", as: "select_action_game"   # resourceにぶら下げたカスタムPOST
  # post "/game/advance_cut",    to: "games#advance_cut",   as: "advance_cut_game"     # resourceにぶら下げたカスタムPOST
  # post "games/select_action",  to: "games#select_action", as: "select_action"        # 元のコード
  # post "games/advance_cut",    to: "games#advance_cut",   as: "advance_cut"          # 元のコード
  root to: "games#play"

  get "/privacy_policy", to: "public_pages#privacy", as: :privacy_policy
  get "/term",           to: "public_pages#term",    as: :term
  get "/about",          to: "public_pages#about",   as: :about

  resources :password_resets, param: :token, only: [:new, :create, :edit, :update] do
    collection do
      get :create_page
      get :complete_update
    end
  end
    # get   "/password_resets/new",           to: "password_resets#new",    as: "new_password_reset"          # ← resourcesが展開
    # post  "/password_resets",               to: "password_resets#create", as: "password_resets"             # ← resourcesが展開
    # get   "/password_resets/:token/edit",   to: "password_resets#edit",   as: "edit_password_reset"         # ← resourcesが展開（:tokenがURLに入る）
    # patch "/password_resets/:token",        to: "password_resets#update", as: "password_reset"              # ← resourcesが展開
    # get   "/password_resets/new",           to: "password_resets#new",    as: "new_password_reset"          # 元のコード
    # post  "/password_resets",               to: "password_resets#create", as: "password_resets"             # 元のコード
    # get   "/password_resets/edit",          to: "password_resets#edit",   as: "edit_password_reset"         # 元のコード
    # patch "/password_resets/update",        to: "password_resets#update", as: "update_password_reset"       # 元のコード

    # get   "/password_resets/create_page",     to: "password_resets#create_page",     as: "create_page_password_resets"      # collectionでぶら下げ
    # get   "/password_resets/complete_update", to: "password_resets#complete_update", as: "complete_update_password_resets"  # collectionでぶら下げ
    # get   "/password_resets/create",          to: "password_resets#create_page",     as: "password_resets_create"           # 元のコード
    # get   "/password_resets/complete_update", to: "password_resets#complete_update", as: "complete_update_password_reset"   # 元のコード

  get "/line_login", to: "oauths#line_login", as: "line_login"
  match "/auth/:provider/callback", to: "oauths#callback", via: %i[get post]
  get "/auth/failure",            to: redirect("/")

  get   "/complete_profile", to: "users#complete_profile", as: :complete_profile
  patch "/complete_profile", to: "users#update_profile",   as: :update_profile

  get   "/settings", to: "settings#show", as: :settings
  get   "/settings/line_notification", to: "line_notification_settings#show", as: :settings_line_notification
  patch "/settings/line_notification", to: "line_notification_settings#update"
  get   "/settings/delete_account", to: "delete_account#show", as: :delete_account
  delete "/settings/delete_account", to: "delete_account#destroy"

  post "/webhooks/line", to: "line_webhooks#callback"

  get "/status", to: "status#show", as: :status

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
