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

ActiveRecord::Schema[8.0].define(version: 2025_07_07_120406) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_choices", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "position", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_action_choices_on_event_id"
    t.check_constraint "\"position\" >= 1 AND \"position\" <= 4", name: "action_choices_position_check"
  end

  create_table "action_results", force: :cascade do |t|
    t.bigint "action_choice_id", null: false
    t.integer "priority", null: false
    t.jsonb "trigger_conditions", default: {}, null: false
    t.jsonb "effects"
    t.integer "next_derivation_number"
    t.bigint "calls_event_set_id"
    t.boolean "resolves_loop", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_choice_id", "priority"], name: "index_action_results_on_action_choice_id_and_priority", unique: true
    t.index ["action_choice_id"], name: "index_action_results_on_action_choice_id"
    t.index ["calls_event_set_id"], name: "index_action_results_on_calls_event_set_id"
    t.check_constraint "NOT (next_derivation_number IS NOT NULL AND calls_event_set_id IS NOT NULL)", name: "action_results_mutual_exclusion_check"
  end

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid"
  end

  create_table "cable_tables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cache_tables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cuts", force: :cascade do |t|
    t.bigint "action_result_id", null: false
    t.integer "position", default: 1, null: false
    t.text "message", null: false
    t.string "character_image", null: false
    t.string "background_image", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_result_id", "position"], name: "index_cuts_on_action_result_id_and_position", unique: true
    t.index ["action_result_id"], name: "index_cuts_on_action_result_id"
    t.check_constraint "\"position\" >= 1", name: "cuts_sequence_check"
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "loop_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_event_categories_on_name", unique: true
  end

  create_table "event_sets", force: :cascade do |t|
    t.bigint "event_category_id", null: false
    t.string "name", null: false
    t.jsonb "trigger_conditions", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_category_id", "name"], name: "index_event_sets_on_event_category_id_and_name", unique: true
    t.index ["event_category_id"], name: "index_event_sets_on_event_category_id"
  end

  create_table "event_temporary_data", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "reception_count", default: 0, null: false
    t.integer "success_count", default: 0, null: false
    t.datetime "started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "special_condition"
    t.datetime "ended_at"
    t.index ["user_id"], name: "index_event_temporary_data_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "event_set_id", null: false
    t.string "name"
    t.integer "derivation_number", default: 0, null: false
    t.text "message", null: false
    t.string "character_image", null: false
    t.string "background_image", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_set_id", "name"], name: "index_events_on_event_set_id_and_name", unique: true
    t.index ["event_set_id"], name: "index_events_on_event_set_id"
  end

  create_table "play_states", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "current_event_id", null: false
    t.integer "action_choices_position"
    t.integer "action_results_priority"
    t.integer "current_cut_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_event_id"], name: "index_play_states_on_current_event_id"
    t.index ["user_id"], name: "index_play_states_on_user_id"
  end

  create_table "queue_tables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_event_category_invalidations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_category_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_category_id"], name: "index_user_event_category_invalidations_on_event_category_id"
    t.index ["user_id", "event_category_id"], name: "index_user_event_cat_invalidations_on_user_and_category", unique: true
    t.index ["user_id"], name: "index_user_event_category_invalidations_on_user_id"
  end

  create_table "user_statuses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "hunger_value", default: 50, null: false
    t.integer "happiness_value", default: 10, null: false
    t.integer "love_value", default: 0, null: false
    t.integer "mood_value", default: 0, null: false
    t.integer "sports_value", default: 0, null: false
    t.integer "art_value", default: 0, null: false
    t.integer "money", default: 0, null: false
    t.bigint "current_loop_event_set_id"
    t.datetime "current_loop_started_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "arithmetic", default: 0, null: false
    t.integer "arithmetic_effort", default: 0, null: false
    t.integer "japanese", default: 0, null: false
    t.integer "japanese_effort", default: 0, null: false
    t.integer "science", default: 0, null: false
    t.integer "science_effort", default: 0, null: false
    t.integer "social_studies", default: 0, null: false
    t.integer "social_effort", default: 0, null: false
    t.integer "arithmetic_training_max_count"
    t.integer "arithmetic_training_fastest_time"
    t.index ["current_loop_event_set_id"], name: "index_user_statuses_on_current_loop_event_set_id"
    t.index ["user_id"], name: "index_user_statuses_on_user_id"
  end

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
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["friend_code"], name: "index_users_on_friend_code", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["line_account"], name: "index_users_on_line_account", unique: true
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "birth_day >= 1 AND birth_day <= 31", name: "birth_day_range"
    t.check_constraint "birth_month >= 1 AND birth_month <= 12", name: "birth_month_range"
    t.check_constraint "friend_code::text ~ '^[0-9]{8}$'::text", name: "friend_code_format"
  end

  add_foreign_key "action_choices", "events"
  add_foreign_key "action_results", "action_choices"
  add_foreign_key "action_results", "event_sets", column: "calls_event_set_id"
  add_foreign_key "cuts", "action_results"
  add_foreign_key "event_sets", "event_categories"
  add_foreign_key "event_temporary_data", "users"
  add_foreign_key "events", "event_sets"
  add_foreign_key "play_states", "events", column: "current_event_id"
  add_foreign_key "play_states", "users"
  add_foreign_key "user_event_category_invalidations", "event_categories"
  add_foreign_key "user_event_category_invalidations", "users"
  add_foreign_key "user_statuses", "event_sets", column: "current_loop_event_set_id"
  add_foreign_key "user_statuses", "users"
end
