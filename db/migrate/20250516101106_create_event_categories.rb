class CreateEventCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :event_categories do |t|
      t.string :name
      t.text :description
      t.integer :loop_minutes

      t.timestamps
      t.index :name, unique: true
    end
  end
end
