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

ActiveRecord::Schema[7.0].define(version: 2023_09_12_154817) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.citext "name"
    t.citext "number"
    t.citext "bank"
    t.boolean "has_checking", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "in_menu"
  end

  create_table "categories", force: :cascade do |t|
    t.citext "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "dcu_entries", force: :cascade do |t|
    t.date "entry_date"
    t.text "account_name"
    t.text "type"
    t.integer "check_number"
    t.text "description"
    t.decimal "amount", precision: 13, scale: 4
    t.decimal "balance", precision: 13, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "file"
    t.index ["account_name"], name: "index_dcu_entries_on_account_name"
    t.index ["entry_date"], name: "index_dcu_entries_on_entry_date"
  end

  create_table "disentries", force: :cascade do |t|
    t.date "trans_date"
    t.date "post_date"
    t.text "description"
    t.decimal "amount", precision: 13, scale: 4
    t.text "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "file"
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
    t.boolean "cleared"
    t.bigint "disentry_id"
    t.index ["account_id"], name: "index_entries_on_account_id"
    t.index ["amount"], name: "index_entries_on_amount"
    t.index ["category_id"], name: "index_entries_on_category_id"
    t.index ["disentry_id"], name: "index_entries_on_disentry_id"
    t.index ["entry_date", "amount"], name: "index_entries_on_entry_date_and_amount"
    t.index ["entry_date"], name: "index_entries_on_entry_date"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "splits", force: :cascade do |t|
    t.bigint "entry_id", null: false
    t.bigint "category_id", null: false
    t.decimal "amount", precision: 13, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_splits_on_category_id"
    t.index ["entry_id"], name: "index_splits_on_entry_id"
  end

  create_table "ynab_entries", force: :cascade do |t|
    t.text "account_name"
    t.text "flag"
    t.text "cleared"
    t.integer "check_number"
    t.date "entry_date"
    t.text "payee"
    t.text "category_name"
    t.text "master_category"
    t.text "sub_category"
    t.text "memo"
    t.decimal "outflow", precision: 13, scale: 4
    t.decimal "inflow", precision: 13, scale: 4
    t.decimal "balance", precision: 13, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_name"], name: "index_ynab_entries_on_account_name"
    t.index ["entry_date"], name: "index_ynab_entries_on_entry_date"
  end

  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "categories"
  add_foreign_key "entries", "disentries"
  add_foreign_key "splits", "categories"
  add_foreign_key "splits", "entries"
end
