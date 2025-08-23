require 'rails_helper'

RSpec.describe "PublicPages", type: :request do
  describe "GET /about" do
    it "returns http success" do
      get about_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /term" do
    it "returns http success" do
      get term_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /privacy" do
    it "returns http success" do
      get privacy_policy_path
      expect(response).to have_http_status(:success)
    end
  end

end
