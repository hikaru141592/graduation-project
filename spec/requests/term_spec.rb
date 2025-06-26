require 'rails_helper'

RSpec.describe "Terms", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/term/show"
      expect(response).to have_http_status(:success)
    end
  end

end
