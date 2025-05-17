require 'rails_helper'

RSpec.describe ActionChoice, type: :model do
  let(:event) { build(:event) }
  let(:valid_attrs) { { event: event, position: 1, label: "なでる" } }

  it '必須項目が揃っていれば有効' do
    choice = build(:action_choice, valid_attrs)
    expect(choice).to be_valid
  end

  it 'event がないと無効' do
    choice = build(:action_choice, valid_attrs.merge(event: nil))
    expect(choice).not_to be_valid
    expect(choice.errors.details[:event]).to include(a_hash_including(error: :blank))
  end

  it 'position は 1〜4 の範囲外だと無効' do
    [ 0, 5 ].each do |pos|
      choice = build(:action_choice, valid_attrs.merge(position: pos))
      expect(choice).not_to be_valid
      expect(choice.errors.details[:position]).to include(a_hash_including(error: :inclusion))
    end
  end

  it 'label がないと無効' do
    choice = build(:action_choice, valid_attrs.merge(label: nil))
    expect(choice).not_to be_valid
    expect(choice.errors.details[:label]).to include(a_hash_including(error: :blank))
  end
end
