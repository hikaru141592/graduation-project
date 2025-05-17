class CreatePlayStates < ActiveRecord::Migration[8.0]
  def change
    create_table :play_states do |t|
      t.references :user, null: false, foreign_key: true
      t.references :current_event, null: false, foreign_key: { to_table: :events }
      t.integer :action_choices_position
      t.integer :action_results_priority
      t.integer :current_cut_position

      t.timestamps
    end
  end
end
