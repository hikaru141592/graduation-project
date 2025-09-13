require 'rails_helper'

RSpec.describe 'ログイン・ログアウト機能', type: :system do
  let(:password) { 'password' }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  before do
    driven_by(:headless_chrome)
  end

  context 'ログイン' do
    it '正しい認証情報でログインできる' do
      login(user)
      Capybara.assert_current_path root_path, ignore_query: true
      expect(page).to have_link I18n.t("buttons.logout")
    end

    it '誤った認証情報ではログインできずエラーメッセージが表示される' do
      visit new_session_path
      fill_in I18n.t("activerecord.attributes.user.email"), with: user.email
      fill_in I18n.t("activerecord.attributes.user.password"), with: 'wrongpass'
      click_button I18n.t("buttons.login")
      Capybara.assert_current_path new_session_path, ignore_query: true
      expect(page).to have_content 'メールアドレスかパスワードが違います。'
    end
  end

  context 'ログアウト' do
    it 'ログアウトできる' do
      login(user)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_link I18n.t("buttons.logout")
      accept_confirm I18n.t("confirmations.logout") do
        click_link I18n.t("buttons.logout")
      end

      expect(page).to have_current_path new_session_path, ignore_query: true
      expect(page).to have_content I18n.t("flash.sessions.destroy.danger")
    end
  end
end
