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
      birth_month:           1,
      birth_day:             15,
      friend_code:           Faker::Number.number(digits: 8)
    }
  end

  it 'ファクトリで作ったユーザーは有効' do
    expect(build(:user)).to be_valid
  end

  %i[email password password_confirmation name egg_name birth_month birth_day].each do |attr|
    it "#{attr} がないと無効" do
      user = build(:user, valid_attrs.merge(attr => nil))
      expect(user).not_to be_valid
      expect(user.errors.details[attr]).to include(a_hash_including(error: :blank))
    end
  end

  it 'emailが重複すると無効' do
    dup = build(:user, valid_attrs.merge(email: existing_user.email))
    expect(dup).not_to be_valid
    expect(dup.errors.details[:email]).to include(a_hash_including(error: :taken))
  end

  it 'nameが6文字以内なら有効' do
    user = build(:user, valid_attrs.merge(name: "山田太郎"))
    expect(user).to be_valid
  end

  it 'nameが7文字以上だと無効' do
    user = build(:user, valid_attrs.merge(name: "あいうえおかき"))
    expect(user).not_to be_valid
    expect(user.errors.details[:name]).to include(a_hash_including(error: :too_long))
  end

  describe 'egg_nameカラムの範囲' do
    it 'egg_nameが6文字以内なら有効' do
      user = build(:user, valid_attrs.merge(egg_name: "たまご"))
      expect(user).to be_valid
    end
    it 'egg_nameが7文字以上だと無効' do
      user = build(:user, valid_attrs.merge(egg_name: "たまごちゃんX"))
      expect(user).not_to be_valid
      expect(user.errors.details[:egg_name]).to include(a_hash_including(error: :too_long))
    end
    it 'egg_nameが「未登録」だと無効（line_registration?がfalseの場合）' do
      user = build(:user, valid_attrs.merge(egg_name: "未登録"))
      user.line_registration = false
      expect(user).not_to be_valid
      expect(user.errors[:egg_name]).to include("には「未登録」という文字列を使用できません")
    end
    it 'egg_nameが「未登録」だと無効（line_registration?がnilの場合）' do
      user = build(:user, valid_attrs.merge(egg_name: "未登録"))
      user.line_registration = nil
      expect(user).not_to be_valid
      expect(user.errors[:egg_name]).to include("には「未登録」という文字列を使用できません")
    end
    it 'egg_nameが「未登録」でもline_registration?がtrueなら有効' do
      user = build(:user, valid_attrs.merge(egg_name: "未登録"))
      user.line_registration = true
      expect(user).to be_valid
    end
  end

  describe '生年月日カラムの範囲' do
    it 'birth_monthが1〜12なら有効' do
      [ 1, 12 ].each do |m|
        user = build(:user, valid_attrs.merge(birth_month: m))
        expect(user).to be_valid
      end
    end
    it 'birth_monthが範囲外だと無効' do
      [ 0, 13 ].each do |m|
        user = build(:user, valid_attrs.merge(birth_month: m))
        expect(user).not_to be_valid
        expect(user.errors.details[:birth_month]).to include(a_hash_including(error: :inclusion))
      end
    end
    it 'birth_dayが1〜31なら有効' do
      [ 1, 31 ].each do |d|
        user = build(:user, valid_attrs.merge(birth_day: d))
        expect(user).to be_valid
      end
    end
    it 'birth_dayが範囲外だと無効' do
      [ 0, 32 ].each do |d|
        user = build(:user, valid_attrs.merge(birth_day: d))
        expect(user).not_to be_valid
        expect(user.errors.details[:birth_day]).to include(a_hash_including(error: :inclusion))
      end
    end
    it '2月30日, 2月31日, 4月31日は無効' do
      [ [ 2, 30 ], [ 2, 31 ], [ 4, 31 ] ].each do |month, day|
        user = build(:user, valid_attrs.merge(birth_month: month, birth_day: day))
        expect(user).not_to be_valid
        expect(user.errors.details[:birth_day]).to include(a_hash_including(error: "は実在しない日付です"))
        expect(user.errors[:birth_day]).to include("は実在しない日付です")
      end
    end
    it '2月29日は有効（うるう年想定）' do
      user = build(:user, valid_attrs.merge(birth_month: 2, birth_day: 29))
      expect(user).to be_valid
    end
    it '3月31日, 12月31日は有効' do
      [ [ 3, 31 ], [ 12, 31 ] ].each do |month, day|
        user = build(:user, valid_attrs.merge(birth_month: month, birth_day: day))
        expect(user).to be_valid
      end
    end
  end

  describe 'friend_codeのフォーマットとユニーク制約' do
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

  it 'reset_password_tokenが重複すると無効' do
    token = "abcdef"
    create(:user, reset_password_token: token)
    user = build(:user, valid_attrs.merge(reset_password_token: token))
    expect(user).not_to be_valid
    expect(user.errors.details[:reset_password_token]).to include(a_hash_including(error: :taken))
  end

  describe 'Userモデルのインスタンスメソッド' do
    describe '#profile_completed?' do
      it '#profile_completed?はegg_nameが「未登録」以外ならtrue' do
        user = build(:user, valid_attrs.merge(egg_name: "たまご"))
        expect(user.profile_completed?).to eq true
      end
      it '#profile_completed?はegg_nameが「未登録」ならfalse' do
        user = build(:user, valid_attrs.merge(egg_name: "未登録"))
        expect(user.profile_completed?).to eq false
      end
    end

    describe '#clear_event_category_invalidations!' do
      it '期限切れのuser_event_category_invalidationsのみ削除される' do
        user = create(:user)
        cat1 = create(:event_category, name: "cat1")
        cat2 = create(:event_category, name: "cat2")
        valid   = user.user_event_category_invalidations.create!(event_category: cat1, expires_at: 2.days.from_now)
        expired = user.user_event_category_invalidations.create!(event_category: cat2, expires_at: 1.day.ago)
        expect { user.clear_event_category_invalidations! }.to change { user.user_event_category_invalidations.count }.by(-1)
        expect(user.user_event_category_invalidations).to include(valid)
        expect(user.user_event_category_invalidations).not_to include(expired)
      end
    end

    describe '#egg_name_with_suffix' do
      it 'name_suffixがno_suffixなら何も付かない' do
        user = build(:user, valid_attrs.merge(egg_name: "たまご", name_suffix: "no_suffix"))
        expect(user.egg_name_with_suffix).to eq "たまご"
      end
      it 'suffixがchanなら「ちゃん」が付く' do
        user = build(:user, valid_attrs.merge(egg_name: "たまご", name_suffix: "chan"))
        expect(user.egg_name_with_suffix).to eq "たまごちゃん"
      end
    end

    describe '#name_suffix_change!' do
      it 'event.nameが「たまごのなまえ」ならpositionに応じてsuffixが変わる' do
        user  = create(:user, name_suffix: "no_suffix")
        event = create(:event, name: "たまごのなまえ")
        user.name_suffix_change!(event, 2)
        expect(user.name_suffix).to eq "chan"
      end
      it 'event.nameが違う場合は変更されない' do
        user  = create(:user, name_suffix: "no_suffix")
        event = create(:event, name: "その他")
        user.name_suffix_change!(event, 2)
        expect(user.name_suffix).to eq "no_suffix"
      end
    end

    describe '#birthday?' do
      it '誕生日当日はtrue' do
        today = Date.new(2025, 6, 15)
        allow(Time).to receive(:current).and_return(today)
        user = build(:user, valid_attrs.merge(birth_month: 6, birth_day: 15))
        expect(user.birthday?).to eq true
      end
      it '誕生日でない日はfalse' do
        today = Date.new(2025, 6, 16)
        allow(Time).to receive(:current).and_return(today)
        user = build(:user, valid_attrs.merge(birth_month: 6, birth_day: 15))
        expect(user.birthday?).to eq false
      end
      it '2/29生まれで非うるう年2/28はtrue' do
        today = Date.new(2025, 2, 28)
        allow(Time).to receive(:current).and_return(today)
        user = build(:user, valid_attrs.merge(birth_month: 2, birth_day: 29))
        expect(user.birthday?).to eq true
      end
    end

    describe '#invalidate_event_category!' do
      it 'event_categoryのinvalidationsが新規or更新される' do
        user = create(:user)
        cat3 = create(:event_category, name: "cat3")
        expires = 2.days.from_now
        expect {
          user.invalidate_event_category!(cat3, expires)
        }.to change { user.user_event_category_invalidations.count }.by(1)
        expect(user.user_event_category_invalidations.last.event_category).to eq cat3
        expect(user.user_event_category_invalidations.last.expires_at.to_i).to eq expires.to_i
      end
      it '既存event_categoryならexpires_atだけ更新' do
        user = create(:user)
        cat4 = create(:event_category, name: "cat4")
        expires1 = 1.day.from_now
        expires2 = 2.days.from_now
        user.invalidate_event_category!(cat4, expires1)
        expect {
          user.invalidate_event_category!(cat4, expires2)
        }.not_to change { user.user_event_category_invalidations.count }
        expect(user.user_event_category_invalidations.last.expires_at.to_i).to eq expires2.to_i
      end
    end

    describe '#line_registration?' do
      it 'line_registrationがtrueならtrue' do
        user = build(:user, valid_attrs)
        user.line_registration = true
        expect(user.line_registration?).to eq true
      end
      it 'line_registrationがfalse/nilならfalse' do
        user = build(:user, valid_attrs)
        user.line_registration = false
        expect(user.line_registration?).to eq false
        user.line_registration = nil
        expect(user.line_registration?).to eq false
      end
    end
  end
end
