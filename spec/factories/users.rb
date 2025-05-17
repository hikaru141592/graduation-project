FactoryBot.define do
  factory :user do
    email                 { Faker::Internet.unique.email }
    password              { "password" }
    password_confirmation { "password" }
    name                  { "テスト太郎" }
    egg_name              { "たまごちゃん" }
    birth_month           { 1 }
    birth_day             { 1 }

    friend_code           { Faker::Number.number(digits: 8) }

    line_account                         { nil }
    line_notifications_enabled           { false }
    last_login_at                        { nil }
    last_logout_at                       { nil }
    last_activity_at                     { nil }
    last_login_from_ip_address           { nil }
  end
end
