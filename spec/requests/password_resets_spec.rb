require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let(:user) { create(:user) }

  describe 'GET /password_resets/new' do
    it '正常に表示される' do
      get new_password_reset_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('パスワード再発行')
    end
  end

  describe 'POST /password_resets' do
    it 'メール送信後 /password_resets/create_pageへリダイレクトし、ビューが表示される' do
      post password_resets_path, params: { email: user.email }

      expect(response).to redirect_to create_page_password_resets_path
      follow_redirect!

      expect(response).to have_http_status(:success)
      expect(response.body).to include('パスワード再発行の案内メールを送信しました')
      expect(response.body).to include('受信メールを確認してください')
    end
  end

  describe 'GET /password_resets/create_page' do
    it '確認ページが表示される' do
      get create_page_password_resets_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('パスワード再発行')
    end
  end

  describe 'GET /password_resets/edit' do
    it '正しいトークン付きで編集ページが表示される' do
      user.deliver_reset_password_instructions!
      get edit_password_reset_path(user.reset_password_token)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('新しいパスワードの登録')
    end
  end

  describe 'PATCH /password_resets/update' do
    it 'パスワードを変更し完了ページへリダイレクトする' do
      user.deliver_reset_password_instructions!
      patch password_reset_path(user.reset_password_token),
            params: {
              user: {
                password:              'newpassword',
                password_confirmation: 'newpassword'
              }
            }

      expect(response).to redirect_to complete_update_password_resets_path
      follow_redirect!

      expect(response).to have_http_status(:success)
      expect(response.body).to include('パスワードの再登録が完了しました。')
    end
  end
end
