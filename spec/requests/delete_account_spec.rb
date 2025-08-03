require 'rails_helper'

RSpec.describe "DeleteAccounts", type: :request do
  describe "GET /show" do
    xit "returns http success" do
      get "/delete_account/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    xit "returns http success" do
      get "/delete_account/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
