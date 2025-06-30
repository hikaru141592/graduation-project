class UserEventCategoryInvalidation < ApplicationRecord
  belongs_to :user
  belongs_to :event_category

  validates :expires_at, presence: true
end
