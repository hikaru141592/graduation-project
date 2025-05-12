require 'rails_helper'

RSpec.describe "サインアップ（クライアントバリデーション）", type: :system, js: true do
  let(:user_attrs) { attributes_for(:user) }

  before do
    driven_by :headless_chrome
    visit signup_path
  end

  it "必須フィールドに入力せずに送信すると送信が抑制される" do
    click_button '登録する'
    expect(current_path).to eq(signup_path)
  end

  it "すべての入力欄に required 属性が付いている" do
    %w[
      email
      password
      password_confirmation
      name
      egg_name
      birth_month
      birth_day
    ].each do |attr|
      expect(page).to have_selector("input[name='user[#{attr}]'][required]"),
        "user[#{attr}] に required 属性が付いていません"
    end
  end

  it "validationMessage が出ている" do
    is_valid = page.evaluate_script("document.querySelector('form').checkValidity()")
    expect(is_valid).to eq(false)
    msg = page.evaluate_script(
      "document.querySelector('input[name=\"user[email]\"]').validationMessage"
    )
    expect(msg).not_to be_empty
  end
end
