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

ActiveRecord::Schema[7.2].define(version: 2025_07_10_152108) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "mission_priority", ["low", "medium", "high"]
  create_enum "mission_status", ["active", "accepted", "submitted", "completed"]
  create_enum "mission_type", ["page_create", "page_update", "image_upload", "page_translate"]

  create_table "discord_users", force: :cascade do |t|
    t.string "discord_uid"
    t.string "username"
    t.string "global_username"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "missions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "wiki_page"
    t.string "language"
    t.string "map_link"
    t.string "discord_post_link"
    t.string "discord_post_uid"
    t.bigint "issuer_id", null: false
    t.bigint "assignee_id"
    t.enum "status", default: "active", null: false, enum_type: "mission_status"
    t.enum "type", default: "page_create", null: false, enum_type: "mission_type"
    t.enum "priority", default: "low", null: false, enum_type: "mission_priority"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_missions_on_assignee_id"
    t.index ["issuer_id"], name: "index_missions_on_issuer_id"
  end

  create_table "wiki_users", force: :cascade do |t|
    t.string "username"
    t.bigint "discord_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_user_id"], name: "index_wiki_users_on_discord_user_id"
  end

  add_foreign_key "missions", "discord_users", column: "assignee_id"
  add_foreign_key "missions", "discord_users", column: "issuer_id"
end
