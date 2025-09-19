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
      false_eval = instance_double(ConditionEvaluator, conditions_met?: false)
      true_eval  = instance_double(ConditionEvaluator, conditions_met?: true)

      allow(ConditionEvaluator).to receive(:new).and_return(false_eval, true_eval)
      result1 = create(:action_result, action_choice: choice, priority: 1)
      result2 = create(:action_result, action_choice: choice, priority: 2)
      expect(choice.selected_result(user)).to eq(result2)
    end

    it 'selected_resultメソッドは条件を満たすaction_resultがなければ最初のaction_resultを返す' do
      false_eval = instance_double(ConditionEvaluator, conditions_met?: false)

      allow(ConditionEvaluator).to receive(:new).and_return(false_eval, false_eval)
      result1 = create(:action_result, action_choice: choice, priority: 1)
      result2 = create(:action_result, action_choice: choice, priority: 2)
      expect(choice.selected_result(user)).to eq(result1)
    end
  end
end
