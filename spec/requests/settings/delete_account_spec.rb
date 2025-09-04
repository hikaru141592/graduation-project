require "rails_helper"

RSpec.describe "Settings::Accounts", type: :request do
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  before do
    post session_path, params: { email: user.email, password: "password" }
  end

  describe "GET /settings/delete_account" do
    it "returns http success" do
      get settings_delete_account_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /settings/delete_account" do
    it "deletes the account and redirects" do
      expect {
        delete settings_delete_account_path
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
