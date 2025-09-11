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

  describe 'バリデーションチェック' do
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

    it '派生番号がないと無効になる' do
      ev = build(:event, valid_attrs.merge(derivation_number: nil))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:derivation_number]).to include(a_hash_including(error: :blank))
    end

    it 'メッセージがないと無効になる' do
      ev = build(:event, valid_attrs.merge(message: nil))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:message]).to include(a_hash_including(error: :blank))
    end

    it 'キャラクター画像がないと無効になる' do
      ev = build(:event, valid_attrs.merge(character_image: nil))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:character_image]).to include(a_hash_including(error: :blank))
    end

    it '背景画像がないと無効になる' do
      ev = build(:event, valid_attrs.merge(background_image: nil))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:background_image]).to include(a_hash_including(error: :blank))
    end

    it '派生番号は0以上でなければ無効になる' do
      ev = build(:event, valid_attrs.merge(derivation_number: -1))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:derivation_number]).to include(a_hash_including(error: :greater_than_or_equal_to))
    end

    it '派生番号は整数でなければ無効になる' do
      ev = build(:event, valid_attrs.merge(derivation_number: 1.5))
      expect(ev).not_to be_valid
      expect(ev.errors.details[:derivation_number]).to include(a_hash_including(error: :not_an_integer))
    end
  end

  describe 'インスタンスメソッド' do
    let(:event) { create(:event, valid_attrs) }
    let!(:choice1) { create(:action_choice, event: event, position: 2) }
    let!(:choice2) { create(:action_choice, event: event, position: 1) }

    it 'ordered_action_choicesはposition順で並ぶ' do
      expect(event.ordered_action_choices.map(&:position)).to eq([ 1, 2 ])
    end

    it 'arithmetic_quiz_being_asked?はevent_set.nameが算数かつderivation_numberが1..4ならtrue' do
      event.event_set.name = '算数'
      event.derivation_number = 3
      expect(event.arithmetic_quiz_being_asked?).to be true
    end

    it 'arithmetic_quiz_being_asked?は条件外ならfalse' do
      event.event_set.name = '国語'
      event.derivation_number = 3
      expect(event.arithmetic_quiz_being_asked?).to be false
      event.event_set.name = '算数'
      event.derivation_number = 5
      expect(event.arithmetic_quiz_being_asked?).to be false
    end

    it 'selected_choice(position)は該当positionのaction_choiceを返す' do
      expect(event.selected_choice(1)).to eq(choice2)
      expect(event.selected_choice(2)).to eq(choice1)
    end
    it 'selected_choice(position)で存在しないpositionは例外を投げる' do
      expect { event.selected_choice(99) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
