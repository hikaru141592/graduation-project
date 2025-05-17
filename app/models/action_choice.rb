class ActionChoice < ApplicationRecord
  belongs_to :event
  has_many   :action_results, dependent: :destroy

  validates :position, presence: true, inclusion: { in: 1..4 }
  validates :label,    presence: true
end
