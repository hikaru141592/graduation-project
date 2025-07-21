require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:existing_user) { create(:user) }
  let(:valid_attrs) do
    {
      email:                 Faker::Internet.unique.email,
      password:              "password",
      password_confirmation: "password",
      name:                  "太郎",
      egg_name:              "たまご",
      birth_month:           6,
      birth_day:             15,
      friend_code:           Faker::Number.number(digits: 8)
    }
  end

  it 'ファクトリで作ったユーザーは有効' do
    expect(build(:user)).to be_valid
  end

  it 'email がなければ無効' do
    user = build(:user, valid_attrs.merge(email: nil))
    expect(user).not_to be_valid
    expect(user.errors.details[:email]).to include(a_hash_including(error: :blank))
  end

  it 'email が重複すると無効' do
    dup = build(:user, valid_attrs.merge(email: existing_user.email))
    expect(dup).not_to be_valid
    expect(dup.errors.details[:email]).to include(a_hash_including(error: :taken))
  end

  it 'name が6文字以内なら有効' do
    user = build(:user, valid_attrs.merge(name: "山田太郎"))
    expect(user).to be_valid
  end

  it 'name が7文字以上だと無効' do
    user = build(:user, valid_attrs.merge(name: "あいうえおかき"))
    expect(user).not_to be_valid
    expect(user.errors.details[:name]).to include(a_hash_including(error: :too_long))
  end

  it 'egg_name が6文字以内なら有効' do
    user = build(:user, valid_attrs.merge(egg_name: "たまご"))
    expect(user).to be_valid
  end

  it 'egg_name が7文字以上だと無効' do
    user = build(:user, valid_attrs.merge(egg_name: "たまごちゃんX"))
    expect(user).not_to be_valid
    expect(user.errors.details[:egg_name]).to include(a_hash_including(error: :too_long))
  end

  describe '生年月日カラムの範囲' do
    it 'birth_month が 1〜12 なら有効' do
      [ 1, 12 ].each do |m|
        user = build(:user, valid_attrs.merge(birth_month: m))
        expect(user).to be_valid
      end
    end

    it 'birth_month が範囲外だと無効' do
      [ 0, 13 ].each do |m|
        user = build(:user, valid_attrs.merge(birth_month: m))
        expect(user).not_to be_valid
        expect(user.errors.details[:birth_month]).to include(a_hash_including(error: :inclusion))
      end
    end

    it 'birth_day が 1〜31 なら有効' do
      [ 1, 31 ].each do |d|
        user = build(:user, valid_attrs.merge(birth_day: d))
        expect(user).to be_valid
      end
    end

    it 'birth_day が範囲外だと無効' do
      [ 0, 32 ].each do |d|
        user = build(:user, valid_attrs.merge(birth_day: d))
        expect(user).not_to be_valid
        expect(user.errors.details[:birth_day]).to include(a_hash_including(error: :inclusion))
      end
    end
  end

  describe 'friend_code のフォーマットとユニーク制約' do
    it '8桁数字なら有効' do
      user = build(:user, valid_attrs.merge(friend_code: "12345678"))
      expect(user).to be_valid
    end

    it '8桁以外や数字以外だと無効' do
      [ "1234567", "123456789", "abcdefgh" ].each do |code|
        u = build(:user, valid_attrs.merge(friend_code: code))
        expect(u).not_to be_valid
        expect(u.errors.details[:friend_code]).to include(a_hash_including(error: :invalid))
      end
    end

    it '重複すると無効' do
      dup = build(:user, valid_attrs.merge(friend_code: existing_user.friend_code))
      expect(dup).not_to be_valid
      expect(dup.errors.details[:friend_code]).to include(a_hash_including(error: :taken))
    end
  end
end
