module AuthenticationMacros
  def login(user, password = 'password')
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',     with: password
    click_button 'ログイン'
  end

  def sign_up_as(attrs)
    visit signup_path
    fill_in 'メールアドレス',           with: attrs[:email]
    fill_in 'パスワード（6文字以上）',   with: attrs[:password]
    fill_in 'パスワード（確認用）',       with: attrs[:password_confirmation]
    fill_in 'ユーザー名（6文字以内）',   with: attrs[:name]
    fill_in 'たまごちゃん名（6文字以内）', with: attrs[:egg_name]
    fill_in '誕生月',                   with: attrs[:birth_month]
    fill_in '誕生日（日）',            with: attrs[:birth_day]
    click_button '登録する'
  end
end