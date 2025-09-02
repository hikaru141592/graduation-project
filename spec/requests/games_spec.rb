require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "GET / (root)" do
    it "未ログイン時はログインページへリダイレクトされる" do
      get root_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
