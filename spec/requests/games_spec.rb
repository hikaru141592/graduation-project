require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "GET /play" do
    it "returns http success" do
      get "/games/play"
      expect(response).to have_http_status(:success)
    end
  end

end
