require 'rails_helper'

RSpec.describe "ユーザー登録", type: :request do
  let(:valid_attributes)   { attributes_for(:user) }
  let(:invalid_attributes) { attributes_for(:user, email: "", birth_month: 0) }

  describe "GET /signup" do
    it "200 OK が返る" do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /signup" do
    context "有効なパラメータの場合" do
      it "User が 1 件増え、ログイン画面にリダイレクトされる" do
        expect {
          post signup_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("登録が完了しました。ログインしてください。")
      end
    end

    context "無効なパラメータの場合" do
      it "200 OK で再描画され、インラインエラーが表示される" do
        post signup_path, params: { user: invalid_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("メールアドレスを入力してください")
        expect(response.body).to include("誕生月は一覧にありません")
      end
    end
  end
end
