require 'rails_helper'

RSpec.describe "サインアップ（クライアントバリデーション）", type: :system, js: true do
  let(:user_attrs) { attributes_for(:user) }

  before do
    driven_by :headless_chrome
    visit new_user_path
  end

  it "必須フィールドに入力せずに送信すると送信が抑制される" do
    click_button I18n.t("buttons.register")
    expect(current_path).to eq(new_user_path)
  end

  it "すべての入力欄にrequired属性が付いている" do
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
        "user[#{attr}] にrequired属性が付いていません"
    end
  end

  it "validationMessageが出ている" do
    is_valid = page.evaluate_script("document.querySelector('form').checkValidity()")
    expect(is_valid).to eq(false)
    msg = page.evaluate_script(
      "document.querySelector('input[name=\"user[email]\"]').validationMessage"
    )
    expect(msg).not_to be_empty
  end
end
