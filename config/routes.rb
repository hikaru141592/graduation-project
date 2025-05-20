Rails.application.routes.draw do
  get  "signup", to: "users#new",    as: "signup"
  post "signup", to: "users#create"

  get    "login",  to: "sessions#new",     as: "login"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"

  post "games/select_action", to: "games#select_action", as: "select_action"

  root to: "games#play"
end
