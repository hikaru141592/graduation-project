class AddImageChangeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :image_change, :boolean, default: true, null: false
  end
end
