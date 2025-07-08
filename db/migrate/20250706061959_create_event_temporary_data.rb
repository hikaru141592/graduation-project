class CreateEventTemporaryData < ActiveRecord::Migration[8.0]
  def change
    create_table :event_temporary_data do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :reception_count, default: 0, null: false
      t.integer :success_count, default: 0, null: false
      t.datetime :started_at

      t.timestamps
    end
  end
end
