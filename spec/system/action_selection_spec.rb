# spec/system/action_selection_spec.rb
require 'rails_helper'

RSpec.describe 'ゲームプレイ画面 行動選択機能', type: :system, js: true do
  include AuthenticationMacros

  let(:password) { 'password' }
  let!(:user)    { create(:user, password: password, password_confirmation: password) }

  before do
    # ステータス・プレイステートを初期化
    UserStatus.find_or_create_by!(user: user) do |status|
      status.update!(hunger_value: 50, happiness_value: 10)
    end

    PlayState.find_or_create_by!(user: user) do |ps|
      first_set   = EventSet.find_by!(name: '何か言っている')
      first_event = Event.find_by!(event_set: first_set, derivation_number: 0)
      ps.update!(
        current_event_id:        first_event.id,
        action_choices_position: nil,
        action_results_priority: nil,
        current_cut_position:    nil
      )
    end

    driven_by :headless_chrome
    login(user)

    # ログイン成功を保証
    expect(page).to have_current_path(root_path, ignore_query: true),
                    'ログインに失敗しています'
  end

  # テスト対象のラベル
  LABELS = %w[
    はなしをきいてあげる
    よしよしする
    おやつをあげる
    ごはんをあげる
  ].freeze

  LABELS.each do |label|
    it "「#{label}」ボタンを押したら priority1 の ActionResult が選ばれカット1へ進む" do
      # ボタンが存在し有効か
      expect(page).to have_button(label, disabled: false)

      # ボタン押下
      click_button label
      expect(page).to have_selector('button', text: 'すすむ', count: 1)

      # play_states が更新されたか
      ps = user.play_state.reload
      expect(ps.action_choices_position).to be_between(1, 4)
      expect(ps.action_results_priority).to eq 1
      expect(ps.current_cut_position).to eq 1

      # メッセージボックスが表示されているか
      expect(page).to have_css('.message-box')
    end
  end
end
