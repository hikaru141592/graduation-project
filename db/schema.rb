# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_07_122515) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.string "salt", null: false
    t.string "name", limit: 6, null: false
    t.string "egg_name", limit: 6, null: false
    t.integer "birth_month", null: false
    t.integer "birth_day", null: false
    t.string "friend_code", limit: 8, null: false
    t.integer "role", default: 0, null: false
    t.string "line_account"
    t.boolean "line_notifications_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["friend_code"], name: "index_users_on_friend_code", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["line_account"], name: "index_users_on_line_account", unique: true
    t.check_constraint "birth_day >= 1 AND birth_day <= 31", name: "birth_day_range"
    t.check_constraint "birth_month >= 1 AND birth_month <= 12", name: "birth_month_range"
    t.check_constraint "friend_code::text ~ '\\A\\d{8}\\z'::text", name: "friend_code_format"
  end
end
