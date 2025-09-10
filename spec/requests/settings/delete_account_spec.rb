require "rails_helper"

RSpec.describe "アカウント削除", type: :request do
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  before do
    post session_path, params: { email: user.email, password: "password" }
  end

  describe "GET /settings/delete_account" do
    it "削除ページが表示される" do
      get settings_delete_account_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t("settings.accounts.show.title"))
      expect(response.body).to include(I18n.t("buttons.user_destroy"))
    end
  end

  describe "DELETE /settings/delete_account" do
    it "アカウント削除後、ログイン画面にリダイレクトされる" do
      expect {
        delete settings_delete_account_path
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("flash.settings.accounts.destroy.danger"))
    end
  end
end
