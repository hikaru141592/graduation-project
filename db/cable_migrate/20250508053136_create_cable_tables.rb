class CreateCableTables < ActiveRecord::Migration[8.0]
  def change
    create_table :cable_tables do |t|
      t.timestamps
    end
  end
end
