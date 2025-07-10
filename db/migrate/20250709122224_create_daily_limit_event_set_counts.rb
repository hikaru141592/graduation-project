class CreateDailyLimitEventSetCounts < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_limit_event_set_counts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event_set, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.integer :count, null: false, default: 0

      t.timestamps

      t.index [:user_id, :event_set_id, :occurred_on], unique: true, name: 'index_daily_limit_counts_on_user_event_set_date'
    end
  end
end
