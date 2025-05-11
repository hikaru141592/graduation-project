require 'rails_helper'

RSpec.describe "サインアップ", type: :system do
  before { driven_by(:rack_test) }

  let(:user_attrs) { attributes_for(:user) }

  it "有効な情報で登録するとログイン画面にリダイレクトされ、成功フラッシュが表示される" do
    sign_up_as(user_attrs)
    expect(current_path).to eq(login_path)
    expect(page).to have_selector(".alert-success", text: "登録が完了しました。ログインしてください。")
  end

  it "必須項目抜けだと同じページにとどまり、フォーム近くにエラーメッセージが出る" do
    sign_up_as(user_attrs.merge(email: "", birth_month: ""))
    expect(current_path).to eq(signup_path)
    within(".field_with_errors input[name='user[email]'] + .error") do
      expect(page).to have_content("メールアドレスを入力してください")
    end
  end
end
