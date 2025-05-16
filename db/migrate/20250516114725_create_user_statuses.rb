class CreateUserStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :level
      t.integer :experience
      t.jsonb :status_data

      t.timestamps
    end
  end
end
