class CreateUserStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_statuses do |t|
      t.references :user, null: false, foreign_key: true,
      t.integer :hunger_value,    null: false, default: 50
      t.integer :happiness_value, null: false, default: 10
      t.integer :love_value,      null: false, default: 0
      t.integer :mood_value,      null: false, default: 0
      t.integer :study_value,     null: false, default:   0
      t.integer :sports_value,    null: false, default:   0
      t.integer :art_value,       null: false, default:   0
      t.integer :money,           null: false, default:   0
      t.references :current_loop_event_set,
                   foreign_key: { to_table: :event_sets }
      t.datetime :current_loop_started_at
      t.timestamps
    end
  end
end
