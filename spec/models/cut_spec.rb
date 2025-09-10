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

  it 'positionが1未満だと無効' do
    cut = build(:cut, valid_attrs.merge(position: 0))
    expect(cut).not_to be_valid
    expect(cut.errors.details[:position]).to include(a_hash_including(error: :greater_than))
  end

  it 'positionが小数だと無効' do
    cut = build(:cut, valid_attrs.merge(position: 1.5))
    expect(cut).not_to be_valid
    expect(cut.errors.details[:position]).to include(a_hash_including(error: :not_an_integer))
  end

  it 'positionが数字以外の文字列だと無効' do
    cut = build(:cut, valid_attrs.merge(position: "abc"))
    expect(cut).not_to be_valid
    expect(cut.errors.details[:position]).to include(a_hash_including(error: :not_a_number))
  end

  %i[action_result position message character_image background_image].each do |attr|
    it "#{attr} がないと無効" do
      cut = build(:cut, valid_attrs.merge(attr => nil))
      expect(cut).not_to be_valid
      expect(cut.errors.details[attr]).to include(a_hash_including(error: :blank))
    end
  end

  describe 'インスタンスメソッド#random_message' do
    let(:cut) { build(:cut, valid_attrs.merge(messages: ["A", "B", "C"])) }

    it 'messagesが空ならmessageを返す' do
      cut.messages = []
      expect(cut.random_message(Time.current)).to eq cut.message
    end

    it 'messagesがあればseedで同じ値を返す' do
      seed = Time.current
      expect(cut.random_message(seed)).to eq cut.random_message(seed)
      expect(["A", "B", "C"]).to include(cut.random_message(seed))
    end
  end
end
