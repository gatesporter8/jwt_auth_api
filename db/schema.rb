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

ActiveRecord::Schema[7.0].define(version: 2024_06_18_215511) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "refresh_tokens", force: :cascade do |t|
    t.boolean "revoked", default: false, null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "token_ciphertext"
    t.string "token_bidx"
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["revoked"], name: "index_refresh_tokens_on_revoked"
    t.index ["token_bidx"], name: "index_refresh_tokens_on_token_bidx", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "refresh_tokens", "users"
end
