require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:set) { build(:event_set) }
  let(:valid_attrs) do
    {
      event_set:        set,
      name:             "サンプルイベント",
      derivation_number: 0,
      message:          "テストメッセージ",
      character_image:  "char.png",
      background_image: "bg.png"
    }
  end

  it '必須項目が揃っていれば有効になる' do
    ev = build(:event, valid_attrs)
    expect(ev).to be_valid
  end

  it 'イベントセットがないと無効になる' do
    ev = build(:event, valid_attrs.merge(event_set: nil))
    expect(ev).not_to be_valid
    expect(ev.errors.details[:event_set]).to include(a_hash_including(error: :blank))
  end

  it '名前がないと無効になる' do
    ev = build(:event, valid_attrs.merge(name: nil))
    expect(ev).not_to be_valid
    expect(ev.errors.details[:name]).to include(a_hash_including(error: :blank))
  end

  it '派生番号は 0 以上でなければ無効になる' do
    ev = build(:event, valid_attrs.merge(derivation_number: -1))
    expect(ev).not_to be_valid
    expect(ev.errors.details[:derivation_number]).to include(a_hash_including(error: :greater_than_or_equal_to))
  end

  it 'メッセージがないと無効になる' do
    ev = build(:event, valid_attrs.merge(message: nil))
    expect(ev).not_to be_valid
    expect(ev.errors.details[:message]).to include(a_hash_including(error: :blank))
  end
end
