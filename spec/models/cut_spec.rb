require 'rails_helper'

RSpec.describe Cut, type: :model do
  let(:action_result) { create(:action_result) }
  let(:valid_attrs) do
    {
      action_result:   action_result,
      position:        1,
      message:         "こんにちは！",
      character_image: "char.png",
      background_image: "bg.png"
    }
  end

  it '必須項目が揃っていれば有効' do
    cut = build(:cut, valid_attrs)
    expect(cut).to be_valid
  end

  it 'action_result がないと無効' do
    cut = build(:cut, valid_attrs.merge(action_result: nil))
    expect(cut).not_to be_valid
    expect(cut.errors.details[:action_result]).to include(a_hash_including(error: :blank))
  end

  it 'position が 1 未満だと無効' do
    cut = build(:cut, valid_attrs.merge(position: 0))
    expect(cut).not_to be_valid
    expect(cut.errors.details[:position]).to include(a_hash_including(error: :greater_than))
  end

  %i[message character_image background_image].each do |attr|
    it "#{attr} がないと無効" do
      cut = build(:cut, valid_attrs.merge(attr => nil))
      expect(cut).not_to be_valid
      expect(cut.errors.details[attr]).to include(a_hash_including(error: :blank))
    end
  end
end
