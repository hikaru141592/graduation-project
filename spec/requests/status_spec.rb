require 'rails_helper'

RSpec.describe "Statuses", type: :request do
  describe "GET /show" do
    xit "returns http success" do
      get "/status/show"
      expect(response).to have_http_status(:success)
    end
  end

end
