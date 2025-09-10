require 'rails_helper'

RSpec.describe PlayState, type: :model do
  let!(:user)   { create(:user) }
  let!(:event)  { create(:event) }
  let!(:choice) { create(:action_choice, event: event, position: 1) }
  let!(:result) { create(:action_result, action_choice: choice, priority: 2) }
  let!(:cut)    { create(:cut, action_result: result, position: 3) }
  let(:valid_attrs) do
    {
      user:                   user,
      current_event:         event,
      action_choices_position: nil,
      action_results_priority: nil,
      current_cut_position:    nil
    }
  end

  it '必須項目が揃っていれば有効' do
    ps = build(:play_state, valid_attrs)
    expect(ps).to be_valid
  end

  it 'userがないと無効' do
    ps = build(:play_state, valid_attrs.merge(user: nil))
    expect(ps).not_to be_valid
    expect(ps.errors.details[:user]).to include(a_hash_including(error: :blank))
  end

  it 'current_eventがないと無効' do
    ps = build(:play_state, valid_attrs.merge(current_event: nil))
    expect(ps).not_to be_valid
    expect(ps.errors.details[:current_event]).to include(a_hash_including(error: :blank))
  end

  %i[action_choices_position action_results_priority current_cut_position].each do |column|
    describe column.to_s do
      it '#{column}が整数なら有効' do
        ps = build(:play_state, valid_attrs.merge(column => 1))
        expect(ps).to be_valid
      end

      it '#{column}がnilなら有効' do
        ps = build(:play_state, valid_attrs.merge(column => nil))
        expect(ps).to be_valid
      end

      it '#{column}が文字列なら無効' do
        ps = build(:play_state, valid_attrs.merge(column => "abc"))
        expect(ps).not_to be_valid
      end

      it '#{column}が小数なら無効' do
        ps = build(:play_state, valid_attrs.merge(column => 1.5))
        expect(ps).not_to be_valid
      end
    end
  end

  describe '#current_choice' do
    it 'action_choices_positionがセットされていれば該当のchoiceを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1))
      expect(ps.current_choice).to eq(choice)
    end
    it 'action_choices_positionがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: nil))
      expect(ps.current_choice).to be_nil
    end
  end

  describe '#current_action_result' do
    it 'action_results_priorityとchoiceがあれば該当のresultを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: 2))
      expect(ps.current_action_result).to eq(result)
    end
    it 'action_results_priorityがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: nil))
      expect(ps.current_action_result).to be_nil
    end
    it 'choiceがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: nil, action_results_priority: 2))
      expect(ps.current_action_result).to be_nil
    end
  end

  describe '#current_cut' do
    it 'current_cut_positionとaction_results_priorityとchoiceがあれば該当のcutを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: 2, current_cut_position: 3))
      expect(ps.current_cut).to eq(cut)
    end
    it 'current_cut_positionがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: 2, current_cut_position: nil))
      expect(ps.current_cut).to be_nil
    end
    it 'resultがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: nil, current_cut_position: 3))
      expect(ps.current_cut).to be_nil
    end
    it 'choiceがnilならnilを返す' do
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: nil, action_results_priority: 2, current_cut_position: 3))
      expect(ps.current_cut).to be_nil
    end
  end

  describe '#event_timeout?' do
    it 'updated_atがTIMEOUTより前ならtrue' do
      ps = build(:play_state, valid_attrs)
      ps.updated_at = PlayState::TIMEOUT.ago - 1.minute
      expect(ps.event_timeout?).to be true
    end

    it 'updated_atがTIMEOUT以内ならfalse' do
      ps = build(:play_state, valid_attrs)
      ps.updated_at = Time.current
      expect(ps.event_timeout?).to be false
    end
  end

  describe '#start_new_event!' do
    it 'current_event_idが更新され、各positionやpriorityがnilになる' do
      next_event = create(:event)
      ps = create(:play_state, valid_attrs.merge(current_event: event, action_choices_position: 1, action_results_priority: 2, current_cut_position: 3))
      ps.start_new_event!(next_event)
      expect(ps.current_event_id).to eq(next_event.id)
      expect(ps.action_choices_position).to be_nil
      expect(ps.action_results_priority).to be_nil
      expect(ps.current_cut_position).to be_nil
    end
  end

  describe '#apply_automatic_update!' do
    it 'user_status.apply_automatic_update!が呼ばれ、touchされる' do
      ps = create(:play_state, valid_attrs)
      expect(ps.user_status).to receive(:apply_automatic_update!).with(ps.updated_at, ps.last_line_update_at)
      expect(ps).to receive(:touch)
      ps.apply_automatic_update!
    end
    it 'perform_touch: falseならapply_automatic_update!が呼ばれ、touchされない' do
      ps = create(:play_state, valid_attrs)
      expect(ps.user_status).to receive(:apply_automatic_update!).with(ps.updated_at, ps.last_line_update_at)
      expect(ps).not_to receive(:touch)
      ps.apply_automatic_update!(perform_touch: false)
    end
  end

  describe '#line_apply_automatic_update!' do
    it 'apply_automatic_update!とrecord_last_line_update_at!が呼ばれる' do
      ps = create(:play_state, valid_attrs)
      expect(ps).to receive(:apply_automatic_update!).with(perform_touch: false)
      expect(ps).to receive(:record_last_line_update_at!)
      ps.line_apply_automatic_update!
    end
  end

  describe '#record_last_line_update_at!' do
    it 'last_line_update_atが更新される' do
      ps = create(:play_state, valid_attrs)
      expect {
        ps.record_last_line_update_at!
      }.to change { ps.reload.last_line_update_at }
    end

    it 'update_atは更新されない' do
      ps = create(:play_state, valid_attrs)
      original_updated_at = ps.updated_at
      ps.record_last_line_update_at!
      expect(ps.reload.updated_at).to eq(original_updated_at)
    end
  end
end
