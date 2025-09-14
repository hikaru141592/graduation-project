require 'rails_helper'

RSpec.describe "PublicPages", type: :request do
  describe "GET /about" do
    it "正常にアクセスでき、テンプレート・タイトル・主要ワードが表示されること" do
      get about_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:about)
      expect(response.body).to include(I18n.t("public_pages.about.title"))
      %w[タマゴ 特徴 ボタン操作].each do |word|
        expect(response.body).to include(word)
      end
    end
  end

  describe "GET /term" do
    it "正常にアクセスでき、テンプレート・タイトル・主要ワードが表示されること" do
      get term_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:term)
      expect(response.body).to include(I18n.t("public_pages.term.title"))
      %w[同意 著作権 禁止事項].each do |word|
        expect(response.body).to include(word)
      end
    end
  end

  describe "GET /privacy" do
    it "正常にアクセスでき、テンプレート・タイトル・主要ワードが表示されること" do
      get privacy_policy_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:privacy)
      expect(response.body).to include(I18n.t("public_pages.privacy.title"))
      %w[情報 メールアドレス 安全管理].each do |word|
        expect(response.body).to include(word)
      end
    end
  end
end
