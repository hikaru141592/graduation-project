require 'rails_helper'

RSpec.describe ConditionEvaluator do
  let(:user) { double(user_status: double(hungry_value: 50)) }

  describe '#conditions_met?' do
    context '複数条件のand/or判定' do
      let(:true_condition)  { { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 10 } }
      let(:false_condition) { { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 100 } }

      it 'and: 真真→true' do
        conds = { "operator" => "and", "conditions" => [ true_condition, true_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq true
      end
      it 'and: 真偽→false' do
        conds = { "operator" => "and", "conditions" => [ true_condition, false_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq false
      end
      it 'and: 偽偽→false' do
        conds = { "operator" => "and", "conditions" => [ false_condition, false_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq false
      end
      it 'or: 真真→true' do
        conds = { "operator" => "or", "conditions" => [ true_condition, true_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq true
      end
      it 'or: 真偽→true' do
        conds = { "operator" => "or", "conditions" => [ true_condition, false_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq true
      end
      it 'or: 偽偽→false' do
        conds = { "operator" => "or", "conditions" => [ false_condition, false_condition ] }
        evaluator = described_class.new(user, conds)
        expect(evaluator.conditions_met?).to eq false
      end
    end

    it 'alwaysがtrueなら必ずtrue' do
      conds = { "always" => true }
      evaluator = described_class.new(user, conds)
      expect(evaluator.conditions_met?).to eq true
    end

    it 'status条件（１つのみ）がtrueならtrue' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 10 }
        ]
      }
      evaluator = described_class.new(user, conds)
      expect(evaluator.conditions_met?).to eq true
    end

    it 'status条件（１つのみ）がfalseならfalse' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "status", "attribute" => "hungry_value", "operator" => ">", "value" => 90 }
        ]
      }
      evaluator = described_class.new(user, conds)
      expect(evaluator.conditions_met?).to eq false
    end

    it 'probability条件（１つのみ）がtrueになる場合' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "probability", "percent" => 100 }
        ]
      }
      evaluator = described_class.new(user, conds)
      allow(evaluator).to receive(:rand).and_return(99)
      expect(evaluator.conditions_met?).to eq true
    end

    it 'probability条件（１つのみ）がfalseになる場合' do
      conds = {
        "operator" => "and",
        "conditions" => [
          { "type" => "probability", "percent" => 0 }
        ]
      }
      evaluator = described_class.new(user, conds)
      allow(evaluator).to receive(:rand).and_return(0)
      expect(evaluator.conditions_met?).to eq false
    end
  end
end
