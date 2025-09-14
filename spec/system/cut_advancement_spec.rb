require 'rails_helper'

RSpec.describe 'ゲームプレイ画面 行動選択後のカット進行機能', type: :system, js: true do
  include AuthenticationMacros

  let(:password) { 'password' }
  let!(:user)    { create(:user, password: password, password_confirmation: password) }

  before do
    driven_by :headless_chrome
    login(user)
    expect(page).to have_current_path(root_path, ignore_query: true), 'ログインに失敗しています'
  end

  context '「何か言っている」イベントで「はなしをきいてあげる」行動を選択し1カット目のとき' do
    it '「つぎへ」を押すと2カット目に進む' do
      event_set = EventSet.find_by!(name: '何か言っている')
      event     = Event.find_by!(event_set: event_set, derivation_number: 0)
      choice_position = event.action_choices.find_by!(label: 'はなしをきいてあげる').position

      user.play_state.update!(
        current_event_id:        event.id,
        action_choices_position: choice_position,
        action_results_priority: 1,
        current_cut_position:    1
      )

      visit current_path
      click_button 'つぎへ'

      expect(page).to have_selector('button', text: 'つぎへ', count: 1)
      ps = user.play_state.reload
      expect(ps.current_event_id).to eq event.id
      expect(ps.action_choices_position).to eq choice_position
      expect(ps.action_results_priority).to eq 1
      expect(ps.current_cut_position).to eq 2
    end
  end

  context '「何か言っている」イベントで「はなしをきいてあげる」行動を選択し2カット目のとき' do
    it '「つぎへ」を押すと次のイベントの行動選択可能フェーズに進む' do
      event_set = EventSet.find_by!(name: '何か言っている')
      event     = Event.find_by!(event_set: event_set, derivation_number: 0)
      choice_position = event.action_choices.find_by!(label: 'はなしをきいてあげる').position

      user.play_state.update!(
        current_event_id:        event.id,
        action_choices_position: choice_position,
        action_results_priority: 1,
        current_cut_position:    2
      )

      visit current_path

      click_button 'つぎへ'

      # 行動選択可能フェーズのフォームの出現を待つ
      # 待たない場合、DB更新前に続きの検証が走ってしまいエラーになる
      within('turbo-frame#game_play') do
        expect(page).to have_css("form[action='#{select_action_game_path}']")
      end

      ps = user.play_state.reload

      puts "DEBUG: ps.current_event_id=#{ps.current_event_id.inspect}"
      puts "DEBUG: ps.action_choices_position=#{ps.action_choices_position.inspect}"
      puts "DEBUG: ps.action_results_priority=#{ps.action_results_priority.inspect}"
      puts "DEBUG: ps.current_cut_position=#{ps.current_cut_position.inspect}"

      expect(ps.action_choices_position).to be_nil
      expect(ps.action_results_priority).to be_nil
      expect(ps.current_cut_position).to be_nil
    end
  end
end
