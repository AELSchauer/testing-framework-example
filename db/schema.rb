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

ActiveRecord::Schema.define(version: 2023_09_16_213838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ab_test_contribution_conversions", force: :cascade do |t|
    t.string "session_id"
    t.bigint "project_id", null: false
    t.bigint "contribution_id"
    t.bigint "user_id"
    t.string "ab_test_name"
    t.string "ab_test_variant"
    t.integer "ab_test_version"
    t.string "status"
    t.jsonb "metadata"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contribution_id"], name: "index_ab_test_contribution_conversions_on_contribution_id"
    t.index ["project_id"], name: "index_ab_test_contribution_conversions_on_project_id"
    t.index ["user_id"], name: "index_ab_test_contribution_conversions_on_user_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "amount"
    t.boolean "paid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_contributions_on_project_id"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_behavior_trackings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_session_id"
    t.string "event_name"
    t.string "browser"
    t.string "device"
    t.string "os"
    t.jsonb "metadata"
    t.string "trackable_type"
    t.string "trackable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_name"], name: "index_user_behavior_trackings_on_event_name"
    t.index ["trackable_type", "trackable_id"], name: "index_user_behavior_trackings_on_trackable"
    t.index ["user_session_id"], name: "index_user_behavior_trackings_on_user_session_id"
  end

  create_table "user_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "session_start", precision: 6
    t.datetime "session_end", precision: 6
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

  add_foreign_key "ab_test_contribution_conversions", "contributions"
  add_foreign_key "ab_test_contribution_conversions", "projects"
  add_foreign_key "ab_test_contribution_conversions", "users"
  add_foreign_key "contributions", "projects"
  add_foreign_key "contributions", "users"
  add_foreign_key "user_behavior_trackings", "user_sessions"
  add_foreign_key "user_sessions", "users"

  create_view "base_contribution_metrics", sql_definition: <<-SQL
      SELECT DISTINCT ubt_main.user_session_id,
      (ubt_main.metadata #>> '{url}'::text[]) AS url,
      ( SELECT count(ubt_sub.user_session_id) AS count
             FROM user_behavior_trackings ubt_sub
            WHERE (((ubt_sub.event_name)::text = 'visit_donation_page'::text) AND ((ubt_sub.metadata ->> 'url'::text) = (ubt_main.metadata #>> '{url}'::text[])) AND (ubt_sub.user_session_id = ubt_main.user_session_id))
            GROUP BY ubt_sub.user_session_id) AS num_page_visits,
      COALESCE(( SELECT count(ubt_sub.user_session_id) AS count
             FROM user_behavior_trackings ubt_sub
            WHERE (((ubt_sub.event_name)::text = 'create_donation'::text) AND ((ubt_sub.metadata ->> 'url'::text) = (ubt_main.metadata #>> '{url}'::text[])) AND (ubt_sub.user_session_id = ubt_main.user_session_id))
            GROUP BY ubt_sub.user_session_id), (0)::bigint) AS num_contributions
     FROM user_behavior_trackings ubt_main
    WHERE ((ubt_main.event_name)::text = ANY (ARRAY[('visit_donation_page'::character varying)::text, ('create_donation'::character varying)::text]));
  SQL
end
