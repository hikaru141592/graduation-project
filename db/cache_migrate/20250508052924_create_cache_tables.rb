class CreateCacheTables < ActiveRecord::Migration[8.0]
  def change
    create_table :cache_tables do |t|
      t.timestamps
    end
  end
end
