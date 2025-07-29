class AddVitalityToUserStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column :user_statuses, :vitality, :integer, default: 150, null: false
  end
end
