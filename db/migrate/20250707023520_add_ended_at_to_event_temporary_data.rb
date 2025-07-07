class AddEndedAtToEventTemporaryData < ActiveRecord::Migration[8.0]
  def change
    add_column :event_temporary_data, :ended_at, :datetime
  end
end
