class AddLineFriendLinkedAndRemoveLineAccount < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :line_friend_linked, :boolean, default: false, null: false
    remove_column :users, :line_account, :string, null: true
  end
end
