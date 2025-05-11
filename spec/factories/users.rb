FactoryBot.define do
  factory :user do
    email                 { Faker::Internet.unique.email }
    password              { "password" }
    password_confirmation { "password" }
    name                  { "テスト太郎" }
    egg_name              { "たまごちゃん" }
    birth_month           { 1 }
    birth_day             { 1 }
  end
end
