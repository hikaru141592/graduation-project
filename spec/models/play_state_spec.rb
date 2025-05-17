require 'rails_helper'

RSpec.describe PlayState, type: :model do
  let(:user)  { create(:user) }
  let(:event) { create(:event) }
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

  it 'user がないと無効' do
    ps = build(:play_state, valid_attrs.merge(user: nil))
    expect(ps).not_to be_valid
    expect(ps.errors.details[:user]).to include(a_hash_including(error: :blank))
  end

  it 'current_event がないと無効' do
    ps = build(:play_state, valid_attrs.merge(current_event: nil))
    expect(ps).not_to be_valid
    expect(ps.errors.details[:current_event]).to include(a_hash_including(error: :blank))
  end

  it 'action_choices_position が整数なら有効' do
    ps = build(:play_state, valid_attrs.merge(action_choices_position: 2))
    expect(ps).to be_valid
  end

  it 'action_results_priority が整数なら有効' do
    ps = build(:play_state, valid_attrs.merge(action_results_priority: 3))
    expect(ps).to be_valid
  end

  it 'current_cut_position が整数なら有効' do
    ps = build(:play_state, valid_attrs.merge(current_cut_position: 4))
    expect(ps).to be_valid
  end
end
