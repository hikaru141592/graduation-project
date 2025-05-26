# spec/system/login_logout_spec.rb
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
      expect(page).to have_link 'ログアウト'
    end

    it '誤った認証情報ではログインできずエラーメッセージが表示される' do
      visit login_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrongpass'
      click_button 'ログイン'
      Capybara.assert_current_path login_path, ignore_query: true
      expect(page).to have_content 'メールアドレスかパスワードが違います。'
    end
  end

  context 'ログアウト' do
    before do
      login(user)
    end

    it 'ログアウトできる' do
      # ① ログインしてトップページへ
      login(user)
      expect(page).to have_current_path root_path, ignore_query: true

      # ② ログアウトリンクがあるか確認
      expect(page).to have_link 'ログアウト'

      # ③ 確認ダイアログを承認しつつクリック
      accept_confirm '本当にログアウトしますか？' do
        click_link 'ログアウト'
      end

      # ④ ログアウト後の検証
      expect(page).to have_current_path login_path, ignore_query: true
      expect(page).to have_content 'ログアウトしました。'
    end
  end
end
