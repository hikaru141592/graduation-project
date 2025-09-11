require 'rails_helper'

RSpec.describe EventCategory, type: :model do
  it '名前がなければ無効になる' do
    category = build(:event_category, name: nil)
    expect(category).not_to be_valid
    expect(category.errors.details[:name]).to include(a_hash_including(error: :blank))
  end

  it '正しい属性であれば有効になる' do
    category = build(:event_category)
    expect(category).to be_valid
  end

  it '名前が重複すると無効になる' do
    create(:event_category, name: "カテゴリA")
    dup = build(:event_category, name: "カテゴリA")
    expect(dup).not_to be_valid
    expect(dup.errors.details[:name]).to include(a_hash_including(error: :taken))
  end

  it 'loop_minutesが整数かつ0以上なら有効' do
    [ 0, 1, 100 ].each do |val|
      category = build(:event_category, loop_minutes: val)
      expect(category).to be_valid
    end
  end

  it 'loop_minutesが負の値だと無効' do
    category = build(:event_category, loop_minutes: -1)
    expect(category).not_to be_valid
    expect(category.errors.details[:loop_minutes]).to include(a_hash_including(error: :greater_than_or_equal_to))
  end

  it 'loop_minutesが小数だと無効' do
    category = build(:event_category, loop_minutes: 1.5)
    expect(category).not_to be_valid
    expect(category.errors.details[:loop_minutes]).to include(a_hash_including(error: :not_an_integer))
  end

  it 'loop_minutesがnilなら有効' do
    category = build(:event_category, loop_minutes: nil)
    expect(category).to be_valid
  end

  it 'categoryを削除すると関連するevent_setsも削除される' do
    category = create(:event_category)
    set = create(:event_set, event_category: category)
    category.destroy
    expect(EventSet.where(id: set.id)).to be_empty
  end

  it 'categoryを削除すると関連するuser_event_category_invalidationsも削除される' do
    category = create(:event_category)
    user     = create(:user)
    inv = create(:user_event_category_invalidation, event_category: category, user: user)
    category.destroy
    expect(UserEventCategoryInvalidation.where(id: inv.id)).to be_empty
  end
end
