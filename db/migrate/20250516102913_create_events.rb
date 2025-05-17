class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :event_set, null: false, foreign_key: true
      t.string :name
      t.integer    :derivation_number, null: false, default: 0
      t.text       :message, null: false
      t.string     :character_image, null: false
      t.string     :background_image, null: false
      t.timestamps
      t.index [ :event_set_id, :name ], unique: true
    end
  end
end
