require 'rails_helper'

RSpec.describe "ログイン", type: :request do
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  describe "GET /session/new" do
    it "200 OKが返る" do
      get new_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("sessions.new.title"))
    end
  end

  describe "POST /session" do
    context "有効な認証情報の場合" do
      it "ログインできてトップページへリダイレクトされる" do
        post session_path, params: { email: user.email, password: "password" }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include(I18n.t("buttons.logout"))
      end
    end

    context "無効な認証情報の場合" do
      it "ログインできずエラーが表示される" do
        post session_path, params: { email: user.email, password: "wrong" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t("flash.sessions.create.danger"))
      end
    end
  end

  describe "DELETE /session" do
    it "ログアウトできてログイン画面にリダイレクトされる" do
      post session_path, params: { email: user.email, password: "password" }
      delete session_path
      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("flash.sessions.destroy.danger"))
    end
  end
end
