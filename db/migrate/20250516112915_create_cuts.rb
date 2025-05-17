class CreateCuts < ActiveRecord::Migration[8.0]
  def change
    create_table :cuts do |t|
      t.references :action_result, null: false, foreign_key: true
      t.integer :position, null: false, default: 1
      t.text :message, null: false
      t.string     :character_image, null: false
      t.string     :background_image, null: false
      t.timestamps
      t.index [ :action_result_id, :position ], unique: true
      t.check_constraint "position >= 1", name: "cuts_sequence_check"
    end
  end
end
