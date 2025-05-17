require 'rails_helper'

RSpec.describe ActionResult, type: :model do
  let(:choice) { build(:action_choice) }
  let(:valid_attrs) do
    {
      action_choice:      choice,
      priority:           1,
      trigger_conditions: { always: true },
      effects:            {}
    }
  end

  it '必須項目が揃っていれば有効' do
    res = build(:action_result, valid_attrs)
    expect(res).to be_valid
  end

  it 'action_choice がないと無効' do
    res = build(:action_result, valid_attrs.merge(action_choice: nil))
    expect(res).not_to be_valid
    expect(res.errors.details[:action_choice]).to include(a_hash_including(error: :blank))
  end

  it 'priority がないと無効' do
    res = build(:action_result, valid_attrs.merge(priority: nil))
    expect(res).not_to be_valid
    expect(res.errors.details[:priority]).to include(a_hash_including(error: :blank))
  end

  it 'trigger_conditions が空だと無効' do
    res = build(:action_result, valid_attrs.merge(trigger_conditions: {}))
    expect(res).not_to be_valid
    expect(res.errors.details[:trigger_conditions]).to include(a_hash_including(error: :blank))
  end

  it '派生番号と calls_event_set の同時設定は無効' do
    event_set = create(:event_set)
    res = build(:action_result,
                valid_attrs.merge(
                  next_derivation_number: 1,
                  calls_event_set: event_set
                ))
    expect(res).not_to be_valid
    expect(res.errors[:base]).to include("派生番号かイベントセットコールのどちらか一方のみ指定してください")
  end

  it 'with_derivation trait は有効' do
    expect(build(:action_result, :with_derivation)).to be_valid
  end

  it 'with_call trait は有効' do
    expect(build(:action_result, :with_call)).to be_valid
  end
end
