class CreateActionResults < ActiveRecord::Migration[8.0]
  def change
    create_table :action_results do |t|
      t.references :action_choice, null: false, foreign_key: true
      t.integer :priority, null: false
      t.jsonb :trigger_conditions, null: false, default: {}
      t.jsonb :effects
      t.integer :next_derivation_number
      t.references :calls_event_set, foreign_key: { to_table: :event_sets }
      t.boolean :resolves_loop, null: false, default: false
      t.timestamps
      t.index      [:action_choice_id, :priority], unique: true
      t.check_constraint(
        "NOT (next_derivation_number IS NOT NULL AND calls_event_set_id IS NOT NULL)",
        name: "action_results_mutual_exclusion_check")
    end
  end
end
