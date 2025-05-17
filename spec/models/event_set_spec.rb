require 'rails_helper'

RSpec.describe EventSet, type: :model do
  let(:category) { build(:event_category) }
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
end
