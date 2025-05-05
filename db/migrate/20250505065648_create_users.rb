class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string  :email,                     null: false
      t.string  :crypted_password,          null: false
      t.string  :salt,                      null: false
      t.string  :name,      limit: 6,      null: false
      t.string  :egg_name,  limit: 6,      null: false
      t.integer :birth_month,              null: false
      t.integer :birth_day,                null: false
      t.string  :friend_code, limit: 8,    null: false
      t.integer :role,      default: 0,    null: false
      t.string  :line_account
      t.boolean :line_notifications_enabled, default: false, null: false

      t.timestamps
    end

    add_index :users, :email,       unique: true
    add_index :users, :friend_code, unique: true
    add_index :users, :line_account,    unique: true

    add_check_constraint :users, 'birth_month BETWEEN 1 AND 12',    name: 'birth_month_range'
    add_check_constraint :users, 'birth_day BETWEEN 1 AND 31',      name: 'birth_day_range'
    add_check_constraint :users, "friend_code ~ '\\A\\d{8}\\z'", name: 'friend_code_format'
  end
end
