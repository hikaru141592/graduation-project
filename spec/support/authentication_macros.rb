module AuthenticationMacros
  def login(user, password = 'password')
    visit new_session_path
    fill_in I18n.t('activerecord.attributes.user.email'),    with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: password
    click_button I18n.t('buttons.login')
  end

  def sign_up_as(attrs)
    visit new_user_path
    fill_in I18n.t('activerecord.attributes.user.email'),                 with: attrs[:email]
    fill_in I18n.t('activerecord.attributes.user.password'),              with: attrs[:password]
    fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: attrs[:password_confirmation]
    fill_in I18n.t('activerecord.attributes.user.name'),                  with: attrs[:name]
    fill_in I18n.t('activerecord.attributes.user.egg_name'),              with: attrs[:egg_name]
    fill_in I18n.t('activerecord.attributes.user.birth_month'),           with: attrs[:birth_month]
    fill_in I18n.t('activerecord.attributes.user.birth_day'),             with: attrs[:birth_day]
    click_button I18n.t('buttons.register')
  end
end
