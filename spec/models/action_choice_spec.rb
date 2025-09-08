require 'rails_helper'

RSpec.describe ActionChoice, type: :model do
  let(:event) { build(:event) }
  let(:valid_attrs) { { event: event, position: 1, label: "なでる" } }

  describe 'バリデーション' do
    it '必須項目が揃っていれば有効' do
      choice = build(:action_choice, valid_attrs)
      expect(choice).to be_valid
    end

    it 'eventがないと無効' do
      choice = build(:action_choice, valid_attrs.merge(event: nil))
      expect(choice).not_to be_valid
      expect(choice.errors.details[:event]).to include(a_hash_including(error: :blank))
    end

    it 'positionがないと無効' do
      choice = build(:action_choice, valid_attrs.merge(position: nil))
      expect(choice).not_to be_valid
      expect(choice.errors.details[:position]).to include(a_hash_including(error: :blank))
    end

    it 'positionは1〜4の範囲外だと無効' do
      [ 0, 5 ].each do |pos|
        choice = build(:action_choice, valid_attrs.merge(position: pos))
        expect(choice).not_to be_valid
        expect(choice.errors.details[:position]).to include(a_hash_including(error: :inclusion))
      end
    end

      it 'positionが小数だと無効' do
        choice = build(:action_choice, valid_attrs.merge(position: 1.5))
        expect(choice).not_to be_valid
        expect(choice.errors.details[:position]).to include(a_hash_including(error: :not_an_integer))
      end

      it 'positionが文字列だと無効' do
        choice = build(:action_choice, valid_attrs.merge(position: "a"))
        expect(choice).not_to be_valid
        expect(choice.errors.details[:position]).to include(a_hash_including(error: :not_a_number))
      end

    it 'positionは1〜4の範囲内だと有効' do
      [ 1, 2, 3, 4 ].each do |pos|
        choice = build(:action_choice, valid_attrs.merge(position: pos))
        expect(choice).to be_valid
      end
    end

    it 'labelがないと無効' do
      choice = build(:action_choice, valid_attrs.merge(label: nil))
      expect(choice).not_to be_valid
      expect(choice.errors.details[:label]).to include(a_hash_including(error: :blank))
    end
  end

  describe '関連' do
    it 'eventに属する' do
      choice = build(:action_choice, valid_attrs)
      expect(choice.event).to eq(event)
    end

    it 'action_resultsを複数持てる' do
      choice = create(:action_choice, valid_attrs)
      result1 = create(:action_result, action_choice: choice, priority: 1)
      result2 = create(:action_result, action_choice: choice, priority: 2)
      expect(choice.action_results).to include(result1, result2)
    end
  end

  describe 'インスタンスメソッド' do
    let(:choice) { create(:action_choice, valid_attrs) }
    let(:user)   { double('User') }

    it 'selected_resultメソッドは条件を満たすaction_resultを返す' do
      allow(choice).to receive(:conditions_met?).and_return(false, true)
      result1 = create(:action_result, action_choice: choice, priority: 1)
      result2 = create(:action_result, action_choice: choice, priority: 2)
      expect(choice.selected_result(user)).to eq(result2)
    end

    it 'selected_resultメソッドは条件を満たすaction_resultがなければ最初のaction_resultを返す' do
      allow(choice).to receive(:conditions_met?).and_return(false, false)
      result1 = create(:action_result, action_choice: choice, priority: 1)
      result2 = create(:action_result, action_choice: choice, priority: 2)
      expect(choice.selected_result(user)).to eq(result1)
    end
  end

  describe 'プライベートメソッド#conditions_met?' do
    context '複数条件のand/or判定' do
      let(:true_condition)  { { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 10 } }
      let(:false_condition) { { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 100 } }

      it 'and: 真真→true' do
        conds = { "operator" => "and", "conditions" => [true_condition, true_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq true
      end
      it 'and: 真偽→false' do
        conds = { "operator" => "and", "conditions" => [true_condition, false_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq false
      end
      it 'and: 偽偽→false' do
        conds = { "operator" => "and", "conditions" => [false_condition, false_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq false
      end
      it 'or: 真真→true' do
        conds = { "operator" => "or", "conditions" => [true_condition, true_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq true
      end
      it 'or: 真偽→true' do
        conds = { "operator" => "or", "conditions" => [true_condition, false_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq true
      end
      it 'or: 偽偽→false' do
        conds = { "operator" => "or", "conditions" => [false_condition, false_condition] }
        expect(choice.send(:conditions_met?, conds, user)).to eq false
      end
    end

  let(:choice) { ActionChoice.new }
  let(:user) { double(user_status: double(hungry_value: 50)) }

    it 'alwaysがtrueなら必ずtrue' do
      conds = { "always" => true }
      expect(choice.send(:conditions_met?, conds, user)).to eq true
    end

    it 'status条件（１つのみ）がtrueならtrue' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 10 }
        ]
      }
      expect(choice.send(:conditions_met?, conds, user)).to eq true
    end

    it 'status条件（１つのみ）がtrueならfalse' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 90 }
        ]
      }
      expect(choice.send(:conditions_met?, conds, user)).to eq false
    end

    it 'probability条件（１つのみ）がtrueになる場合' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "probability", "percent" => 100 }
        ]
      }
      allow_any_instance_of(Object).to receive(:rand).and_return(99)
      expect(choice.send(:conditions_met?, conds, user)).to eq true
    end

    it 'probability条件（１つのみ）がfalseになる場合' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "probability", "percent" => 0 }
        ]
      }
      allow_any_instance_of(Object).to receive(:rand).and_return(0)
      expect(choice.send(:conditions_met?, conds, user)).to eq false
    end
  end
end
