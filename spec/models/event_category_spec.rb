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
end
