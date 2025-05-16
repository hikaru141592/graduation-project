class CreateEventSets < ActiveRecord::Migration[8.0]
  def change
    create_table :event_sets do |t|
      t.references :event_category, null: false, foreign_key: true
      t.string :name, null: false
      t.jsonb    :trigger_conditions, null: false, default: {}
      t.timestamps
      t.index [:event_category_id, :name], unique: true
    end
  end
end
