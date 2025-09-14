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

  it 'action_choiceがないと無効' do
    res = build(:action_result, valid_attrs.merge(action_choice: nil))
    expect(res).not_to be_valid
    expect(res.errors.details[:action_choice]).to include(a_hash_including(error: :blank))
  end

  it 'priorityがないと無効' do
    res = build(:action_result, valid_attrs.merge(priority: nil))
    expect(res).not_to be_valid
    expect(res.errors.details[:priority]).to include(a_hash_including(error: :blank))
  end

  it 'trigger_conditionsが空だと無効' do
    res = build(:action_result, valid_attrs.merge(trigger_conditions: {}))
    expect(res).not_to be_valid
    expect(res.errors.details[:trigger_conditions]).to include(a_hash_including(error: :blank))
  end

  it 'next_derivation_numberとcalls_event_setの同時設定は無効' do
    event_set = create(:event_set)
    res = build(:action_result, valid_attrs.merge(next_derivation_number: 1,
                                                  calls_event_set: event_set))
    expect(res).not_to be_valid
    expect(res.errors[:base]).to include("派生番号かイベントセットコールのどちらか一方のみ指定してください")
  end

  it 'next_derivation_numberありcalls_event_setなしは有効' do
    expect(build(:action_result, :with_derivation)).to be_valid
  end

  it 'next_derivation_numberなしcalls_event_setありは有効' do
    expect(build(:action_result, :with_call)).to be_valid
  end

  it 'cutsを複数持てる' do
    result = create(:action_result)
    cut1 = create(:cut, action_result: result, position: 1)
    cut2 = create(:cut, action_result: result, position: 2)
    expect(result.cuts).to include(cut1, cut2)
  end

  describe '#apply_derivation' do
    let(:event_set) { create(:event_set) }
    let(:event) { create(:event, event_set: event_set, derivation_number: 2) }
    let(:base_event) { create(:event, event_set: event_set, derivation_number: 0) }
    let(:choice) { create(:action_choice, event: event) }
    let(:result) { build(:action_result, action_choice: choice, next_derivation_number: 2) }

    it '派生先イベントが存在すればそれを返す' do
      event
      expect(result.apply_derivation).to eq [ event_set, event ]
    end

    it '派生先イベントが存在しなければ派生番号0のイベントを返す' do
      base_event
      result.next_derivation_number = 99
      expect(result.apply_derivation).to eq [ event_set, base_event ]
    end
  end
end
