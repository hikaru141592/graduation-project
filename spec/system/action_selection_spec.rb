require 'rails_helper'

RSpec.describe 'ゲームプレイ画面 行動選択機能', type: :system, js: true do
  include AuthenticationMacros

  let(:password) { 'password' }
  let!(:user)    { create(:user, password: password, password_confirmation: password) }

  shared_examples '行動ボタンの共通挙動' do |labels:, priority:|
    labels.each do |label|
      it "「#{label}」を押すと期待どおりのActionResultが選ばれる" do
        expect(page).to have_button(label, disabled: false)

        click_button label
        expect(page).to have_selector('button', text: 'つぎへ', count: 1)

        ps = user.play_state.reload
        expect(ps.action_choices_position).to be_between(1, 4)
        expect(ps.action_results_priority).to eq priority.call(label)
        expect(ps.current_cut_position).to eq 1
      end
    end
  end

  def setup_game(hunger:)
    user.user_status.update!(hunger_value: hunger, happiness_value: 10)

    first_set   = EventSet.find_by!(name: '何か言っている')
    first_event = Event.find_by!(event_set: first_set, derivation_number: 0)

    user.play_state.update!(
      current_event_id:        first_event.id,
      action_choices_position: nil,
      action_results_priority: nil,
      current_cut_position:    nil
    )
  end

  before do
    driven_by :headless_chrome
    login(user)
    expect(page).to have_current_path(root_path, ignore_query: true), 'ログインに失敗しています'
  end

  context 'hunger_valueが50のとき' do
    before do
      setup_game(hunger: 50)
      visit current_path
    end

    include_examples '行動ボタンの共通挙動',
                     labels: %w[はなしをきいてあげる よしよしする おやつをあげる ごはんをあげる],
                     priority: ->(_label) { 1 }
  end

  context 'hunger_valueが90のとき' do
    before do
      setup_game(hunger: 90)
      visit current_path
    end

    include_examples '行動ボタンの共通挙動',
                     labels: %w[はなしをきいてあげる よしよしする おやつをあげる ごはんをあげる],
                     priority: ->(label) { label == 'ごはんをあげる' ? 2 : 1 }
  end
end
