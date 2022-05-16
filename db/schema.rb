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

ActiveRecord::Schema[7.0].define(version: 2022_05_13_125846) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.citext "name"
    t.citext "number"
    t.citext "bank"
    t.boolean "has_checking", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.citext "name"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "entry_date"
    t.integer "check_number"
    t.citext "payee"
    t.decimal "amount", precision: 13, scale: 4
    t.integer "transfer_account_id"
    t.integer "transfer_entry_id"
    t.citext "memo"
    t.decimal "balance", precision: 13, scale: 4
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_entries_on_account_id"
    t.index ["category_id"], name: "index_entries_on_category_id"
  end

  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "categories"
end
