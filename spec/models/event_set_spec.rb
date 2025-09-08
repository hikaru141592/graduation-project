require 'rails_helper'

RSpec.describe EventSet, type: :model do
  let(:category) { create(:event_category) }
  let(:valid_attrs) do
    {
      event_category:     category,
      name:               "サンプルセット",
      trigger_conditions: { always: true }
    }
  end

  it '必須項目が揃っていれば有効になる' do
    set = build(:event_set, valid_attrs)
    expect(set).to be_valid
  end

  it 'イベントカテゴリがないと無効になる' do
    set = build(:event_set, valid_attrs.merge(event_category: nil))
    expect(set).not_to be_valid
    expect(set.errors.details[:event_category]).to include(a_hash_including(error: :blank))
  end

  it '名前が空だと無効になる' do
    set = build(:event_set, valid_attrs.merge(name: nil))
    expect(set).not_to be_valid
    expect(set.errors.details[:name]).to include(a_hash_including(error: :blank))
  end

  it '同一カテゴリ内で名前が重複すると無効になる' do
    create(:event_set, valid_attrs)
    dup = build(:event_set, valid_attrs)
    expect(dup).not_to be_valid
    expect(dup.errors.details[:name]).to include(a_hash_including(error: :taken))
  end

  it 'trigger_conditionsが空だと無効になる' do
    set = build(:event_set, valid_attrs.merge(trigger_conditions: nil))
    expect(set).not_to be_valid
    expect(set.errors.details[:trigger_conditions]).to include(a_hash_including(error: :blank))
  end

  it 'event_setを削除すると関連するeventsも削除される' do
    set = create(:event_set, event_category: category)
    event = create(:event, event_set: set)
    set.destroy
    expect(Event.where(id: event.id)).to be_empty
  end

  it 'event_setを削除すると関連するdaily_limit_event_set_countsも削除される' do
    set = create(:event_set, event_category: category)
    user = create(:user)
    count = DailyLimitEventSetCount.create!(user: user, event_set: set, occurred_on: Date.current, count: 1)
    set.destroy
    expect(DailyLimitEventSetCount.where(id: count.id)).to be_empty
  end
end
