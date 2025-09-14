require 'rails_helper'

RSpec.describe UserStatus, type: :model do
  let(:event_category) { create(:event_category, loop_minutes: 10) }
  let(:event_set) { create(:event_set, event_category: event_category) }

  describe 'nil禁止の属性' do
    required_numeric_attrs = [
      :user,
      :hunger_value,
      :happiness_value,
      :love_value,
      :mood_value,
      :sports_value,
      :art_value,
      :money,
      :arithmetic,
      :arithmetic_effort,
      :japanese,
      :japanese_effort,
      :science,
      :science_effort,
      :social_studies,
      :social_effort,
      :vitality,
      :temp_vitality
    ]
    required_numeric_attrs.each do |attr|
      it "#{attr} がnilだと無効になる" do
        us = build(:user_status, attr => nil)
        expect(us).not_to be_valid
        expect(us.errors.details[attr]).to include(a_hash_including(error: :blank))
      end
    end
  end

  describe 'でも有効な属性' do
    nilable_attrs = [
      :current_loop_event_set,
      :current_loop_started_at,
      :arithmetic_training_max_count,
      :arithmetic_training_fastest_time,
      :ball_training_max_count
    ]
    nilable_attrs.each do |attr|
      it "#{attr} がnilでも有効" do
        us = build(:user_status, attr => nil)
        expect(us).to be_valid
      end
    end
  end

  it 'デフォルト属性で有効になる' do
    us = build(:user_status)
    expect(us).to be_valid
  end

  describe '数値カラムの境界値' do
    default_value_columns = {
      hunger_value:    50,
      happiness_value: 10,
      love_value:      50,
      mood_value:      0,
      sports_value:    0,
      art_value:       0,
      money:           0,
      arithmetic:      0,
      arithmetic_effort: 0,
      japanese:        0,
      japanese_effort: 0,
      science:         0,
      science_effort:  0,
      social_studies:  0,
      social_effort:   0,
      vitality:        150,
      temp_vitality:   150
    }

    default_value_columns.each do |attr, default|
      it "#{attr} が負の値だと無効になる" do
        us = build(:user_status, attr => -1)
        expect(us).not_to be_valid
        expect(us.errors.details[attr]).to include(a_hash_including(error: :greater_than_or_equal_to))
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:user_status) { create(:user_status) }

    describe '#clear_loop_status!' do
      it 'current_loop_event_set_idとcurrent_loop_started_atがnilになる' do
        user_status.update!(current_loop_event_set_id: 1, current_loop_started_at: Time.current)
        user_status.clear_loop_status!
        expect(user_status.current_loop_event_set_id).to be_nil
        expect(user_status.current_loop_started_at).to be_nil
      end
    end

    describe '#in_loop?' do
      before do
        user_status.update!(current_loop_event_set: event_set, current_loop_started_at: Time.current)
        allow(user_status).to receive(:event_set).and_return(event_set)
        allow(user_status).to receive(:event_category).and_return(event_category)
      end
      it 'ループ中ならtrue' do
        expect(user_status.in_loop?).to be true
      end
      it 'ループ外ならfalse' do
        user_status.update!(current_loop_started_at: 20.minutes.ago)
        expect(user_status.in_loop?).to be false
      end
      it 'current_loop_event_set_idがnilならfalse' do
        user_status.update!(current_loop_event_set: nil, current_loop_started_at: nil)
        expect(user_status.in_loop?).to be false
      end
    end

    describe '#loop_timeout?' do
      before do
        user_status.update!(current_loop_event_set: event_set, current_loop_started_at: 20.minutes.ago)
        allow(user_status).to receive(:event_set).and_return(event_set)
        allow(user_status).to receive(:event_category).and_return(event_category)
      end
      it 'ループタイムアウトならtrue' do
        expect(user_status.loop_timeout?).to be true
      end
      it 'ループ中ならfalse' do
        user_status.update!(current_loop_started_at: Time.current)
        expect(user_status.loop_timeout?).to be false
      end
    end

    describe '#record_loop_start!' do
      it 'loop_minutesがnilの場合はセットされない' do
        event_category_no_loop = create(:event_category, loop_minutes: nil)
        event_set_no_loop = create(:event_set, event_category: event_category_no_loop)
        user_status.record_loop_start!(event_set_no_loop)
        expect(user_status.current_loop_event_set_id).to be_nil
        expect(user_status.current_loop_started_at).to be_nil
      end
      it 'current_loop_event_set_idとcurrent_loop_started_atがセットされる' do
        user_status.record_loop_start!(event_set)
        expect(user_status.current_loop_event_set_id).to eq(event_set.id)
        expect(user_status.current_loop_started_at).not_to be_nil
      end
    end

    describe '#apply_automatic_update!' do
      it 'hunger_value, love_value, temp_vitalityが変化する' do
        user_status.update!(hunger_value: 50, love_value: 50, temp_vitality: 100, vitality: 150)
        past = 8.hour.ago
        user_status.apply_automatic_update!(past, past)
        expect(user_status.hunger_value).to be < 50
        expect(user_status.love_value).to be < 50
        expect(user_status.temp_vitality).to be > 100
      end
    end

    describe '#apply_effects!' do
      it 'effectsでhunger_valueが増減する' do
        before = user_status.hunger_value
        user_status.apply_effects!({ "status" => [ { "attribute" => "hunger_value", "delta" => 10 } ] })
        expect(user_status.hunger_value).to eq([ before + 10, 100 ].min)
      end
      it 'effectsで負の値は0未満にならない' do
        user_status.hunger_value = 5
        user_status.apply_effects!({ "status" => [ { "attribute" => "hunger_value", "delta" => -10 } ] })
        expect(user_status.hunger_value).to eq(0)
      end
    end
  end
end
