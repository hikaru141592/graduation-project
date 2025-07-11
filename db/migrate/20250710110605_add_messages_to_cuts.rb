class AddMessagesToCuts < ActiveRecord::Migration[8.0]
  def change
    add_column :cuts, :messages, :jsonb, default: [], null: false
  end
end
