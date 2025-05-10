class FixFriendCodeConstraint < ActiveRecord::Migration[8.0]
  def change
    remove_check_constraint :users, name: 'friend_code_format'
    add_check_constraint :users,
      "friend_code ~ '^[0-9]{8}$'",
      name: 'friend_code_format'
  end
end
