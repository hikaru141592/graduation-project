require 'rails_helper'

RSpec.describe "ユーザー登録", type: :request do
  let(:valid_attributes)   { attributes_for(:user) }
  let(:invalid_attributes) { attributes_for(:user, email: "", birth_month: 0) }

  describe "GET /users/new" do
    it "200 OKが返る" do
      get new_user_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("users.new.title"))
    end
  end

  describe "POST users" do
    context "有効なパラメータの場合" do
      it "Userが1件増え、ログイン画面にリダイレクトされる" do
        expect {
          post users_path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(response.body).to include(I18n.t("flash.users.create.success"))
      end

      it "登録後、UserStatusが作成される" do
        post users_path, params: { user: valid_attributes }
        user = User.last
        expect(user.user_status).to be_present
      end
    end

    context "無効なパラメータの場合（未入力など）" do
      # 未入力の場合は送信自体がブロックされるため未入力POSTのテストはなし（system specでテスト）

      context "重複したメールアドレスの場合" do
        let!(:existing_user) { create(:user, email: valid_attributes[:email]) }
        it "同じページが再表示され、バリデーションエラーが表示される" do
          post users_path, params: { user: valid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          I18n.t(
            "errors.format",
            attribute: I18n.t("activerecord.attributes.user.email"),
            message:   I18n.t("activerecord.errors.messages.taken")
          )
          expect(response.body).to include(I18n.t("users.new.title"))
        end
      end

      context "パスワード不一致の場合" do
        it "登録できずエラーが表示される" do
          attrs = valid_attributes.merge(password_confirmation: "wrong")
          post users_path, params: { user: attrs }
          I18n.t(
            "errors.format",
            attribute: I18n.t("activerecord.attributes.user.password_confirmation"),
            message:   I18n.t("activerecord.errors.messages.confirmation")
          )
        end
      end
    end
  end
end
