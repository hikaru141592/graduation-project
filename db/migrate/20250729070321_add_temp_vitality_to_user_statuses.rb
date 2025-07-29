class AddTempVitalityToUserStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column :user_statuses, :temp_vitality, :integer, default: 150, null: false
  end
end
