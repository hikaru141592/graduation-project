class AddSpecialConditionToEventTemporaryData < ActiveRecord::Migration[8.0]
  def change
    add_column :event_temporary_data, :special_condition, :string
  end
end
