require 'rails_helper'

RSpec.describe 'ゲームプレイ画面 行動選択機能', type: :system, js: true do
  include AuthenticationMacros

  let(:password) { 'password' }
  let!(:user)    { create(:user, password: password, password_confirmation: password) }

  # 共通の期待
  shared_examples '行動ボタンの共通挙動' do |labels:, expected_priority_for:|
    labels.each do |label|
      it "「#{label}」を押すと期待どおりの ActionResult が選ばれる" do
        expect(page).to have_button(label, disabled: false)

        click_button label
        expect(page).to have_selector('button', text: 'すすむ', count: 1)

        ps = user.play_state.reload
        expect(ps.action_choices_position).to be_between(1, 4)
        expect(ps.action_results_priority).to eq expected_priority_for.call(label)
        expect(ps.current_cut_position).to eq 1

        expect(page).to have_css('.message-box')
      end
    end
  end

  def setup_game(hunger:)
    UserStatus.find_or_initialize_by(user: user)
              .update!(hunger_value: hunger, happiness_value: 10)

    PlayState.where(user: user).delete_all
    first_set   = EventSet.find_by!(name: '何か言っている')
    first_event = Event.find_by!(event_set: first_set, derivation_number: 0)

    PlayState.create!(
      user:                    user,
      current_event_id:        first_event.id,
      action_choices_position: nil,
      action_results_priority: nil,
      current_cut_position:    nil
    )
  end

  # 共通ログイン
  before do
    driven_by :headless_chrome
    login(user)
    expect(page).to have_current_path(root_path, ignore_query: true), 'ログインに失敗しています'
  end

  context '空腹値が 50 のとき' do
    before do
      setup_game(hunger: 50)
      visit current_path
    end

    include_examples '行動ボタンの共通挙動',
                     labels: %w[はなしをきいてあげる よしよしする おやつをあげる ごはんをあげる],
                     expected_priority_for: ->(_label) { 1 }
  end

  context '空腹値が 80 のとき' do
    before do
      setup_game(hunger: 80)
      visit current_path
    end

    include_examples '行動ボタンの共通挙動',
                     labels: %w[おやつをあげる ごはんをあげる],
                     expected_priority_for: ->(label) { label == 'ごはんをあげる' ? 2 : 1 }
  end
end
