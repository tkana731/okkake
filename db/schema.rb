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

ActiveRecord::Schema[8.0].define(version: 2025_07_03_034549) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "budgets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "spent", precision: 10, scale: 2, default: "0.0", null: false
    t.date "month", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["user_id", "month", "category_id"], name: "index_budgets_on_user_id_and_month_and_category_id", unique: true
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "color"
    t.string "category_type"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.decimal "total_amount"
    t.decimal "paid_amount"
    t.date "due_date"
    t.string "status"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reservation_type", default: "confirmed", null: false
    t.datetime "lottery_announcement_time"
    t.index ["category_id"], name: "index_reservations_on_category_id"
    t.index ["reservation_type"], name: "index_reservations_on_reservation_type"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.decimal "amount"
    t.string "billing_cycle"
    t.date "next_billing_date"
    t.string "status"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "billing_cycle_type", default: "monthly", null: false, comment: "繰り返し間隔タイプ（daily, weekdays, weekly, biweekly, triweekly, monthly, bimonthly, trimonthly, quarterly, semi_annual, yearly）"
    t.integer "custom_interval", default: 1, comment: "カスタム間隔数（例：2ヶ月ごとの場合は2）"
    t.boolean "weekdays_only", default: false, null: false, comment: "平日（月-金）のみ繰り返すかどうか"
    t.string "holiday_adjustment", default: "none", comment: "祝日調整（none: 調整なし、before: 直前の平日、after: 直後の平日）"
    t.index ["category_id"], name: "index_subscriptions_on_category_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.decimal "amount"
    t.string "transaction_type"
    t.date "transaction_date"
    t.text "memo"
    t.string "vendor"
    t.integer "satisfaction_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "budgets", "categories"
  add_foreign_key "budgets", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "reservations", "categories"
  add_foreign_key "reservations", "users"
  add_foreign_key "subscriptions", "categories"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
end
