Rails.application.routes.draw do
  get  "signup", to: "users#new",    as: "signup"
  post "signup", to: "users#create"

  get    "login",  to: "sessions#new",     as: "login"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  post "games/select_action", to: "games#select_action", as: "select_action"
  post "games/advance_cut",   to: "games#advance_cut",   as: "advance_cut"

  get "/privacy_policy", to: "privacy_policies#show", as: :privacy_policy

  get  "/password_resets/new",     to: "password_resets#new",    as: "new_password_reset"
  post "/password_resets",         to: "password_resets#create", as: "password_resets"
  get   "/password_resets/create",   to: "password_resets#create_page", as: "password_resets_create"
  get   "/password_resets/edit",   to: "password_resets#edit",   as: "edit_password_reset"
  patch "/password_resets/update", to: "password_resets#update", as: "update_password_reset"
  get "/password_resets/complete_update", to: "password_resets#complete_update", as: "complete_update_password_reset"

  match '/auth/:provider/callback', to: 'oauths#callback', via: %i[get post]
  get '/auth/failure',            to: redirect('/')

  get   '/complete_profile', to: 'users#complete_profile', as: :complete_profile
  patch '/complete_profile', to: 'users#update_profile',   as: :update_profile
  #match '/auth/:provider', to: 'oauths#oauth', via: %i[get post], as: :oauth_start

  root to: "games#play"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
