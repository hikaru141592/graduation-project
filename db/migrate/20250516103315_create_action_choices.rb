class CreateActionChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :action_choices do |t|
      t.references :event, null: false, foreign_key: true
      t.integer    :position, null: false
      t.check_constraint "position BETWEEN 1 AND 4", name: "action_choices_position_check"
      t.string     :label
      t.timestamps
    end
  end
end
