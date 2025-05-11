module AuthenticationMacros
  def sign_up_as(attributes)
    visit signup_path
    fill_in 'メールアドレス',           with: user.email
    fill_in 'パスワード（6文字以上）', with: user.password
    fill_in 'パスワード（確認用）',     with: user.password_confirmation
    fill_in 'ユーザー名（6文字以内）', with: user.name
    fill_in 'たまごちゃん名（6文字以内）', with: user.egg_name
    fill_in '誕生月',                   with: user.birth_month
    fill_in '誕生日（日）',            with: user.birth_day
    click_button "登録する"
  end
end
