require 'rails_helper'

RSpec.describe UserStatus, type: :model do
  let(:user) { create(:user) }
  let(:valid_attrs) { { user: user } }

  it 'デフォルト属性で有効になる' do
    us = build(:user_status, valid_attrs)
    expect(us).to be_valid
  end

  it 'user がないと無効になる' do
    us = build(:user_status, valid_attrs.merge(user: nil))
    expect(us).not_to be_valid
    expect(us.errors.details[:user]).to include(a_hash_including(error: :blank))
  end

  describe '数値カラムの境界値' do
    {
      hunger_value:    50,
      happiness_value: 10,
      love_value:      0,
      mood_value:      0,
      study_value:     0,
      sports_value:    0,
      art_value:       0,
      money:           0
    }.each do |attr, default|
      it "#{attr} がデフォルト値 #{default} のとき有効" do
        us = build(:user_status, valid_attrs.merge(attr => default))
        expect(us).to be_valid
      end

      it "#{attr} が負の値だと無効になる" do
        us = build(:user_status, valid_attrs.merge(attr => -1))
        expect(us).not_to be_valid
        expect(us.errors.details[attr]).to include(a_hash_including(error: :greater_than_or_equal_to))
      end
    end
  end

  it 'current_loop_event_set は nil でも有効' do
    us = build(:user_status, valid_attrs.merge(current_loop_event_set: nil))
    expect(us).to be_valid
  end

  it 'current_loop_started_at は nil でも有効' do
    us = build(:user_status, valid_attrs.merge(current_loop_started_at: nil))
    expect(us).to be_valid
  end
end
