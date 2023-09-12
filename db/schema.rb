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

ActiveRecord::Schema.define(version: 2023_09_12_205734) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "contributions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "user_behavior_tracking_events", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_behavior_trackings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_session_id", null: false
    t.bigint "user_behavior_tracking_events_id", null: false
    t.string "browser"
    t.string "device"
    t.string "os"
    t.jsonb "metadata"
    t.string "trackable_type"
    t.string "trackable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trackable_type", "trackable_id"], name: "index_user_behavior_trackings_on_trackable"
    t.index ["user_behavior_tracking_events_id"], name: "index_user_behavior_trackings_on_tracking_events_id"
    t.index ["user_session_id"], name: "index_user_behavior_trackings_on_user_session_id"
  end

  create_table "user_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "session_start"
    t.datetime "session_end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "contributions", "users"
  add_foreign_key "user_behavior_trackings", "user_behavior_tracking_events", column: "user_behavior_tracking_events_id"
  add_foreign_key "user_behavior_trackings", "user_sessions"
  add_foreign_key "user_sessions", "users"
end
