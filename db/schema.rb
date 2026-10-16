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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_012703) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 1, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_admins_on_deleted_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.integer "tax_rate", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "skus", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "code", null: false
    t.string "size"
    t.string "color"
    t.integer "price_yen", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_skus_on_code", unique: true
    t.index ["product_id", "size", "color"], name: "index_skus_on_product_id_and_size_and_color", unique: true, nulls_not_distinct: true
    t.check_constraint "price_yen >= 0", name: "skus_price_yen_non_negative"
    t.check_constraint "stock_quantity >= 0", name: "skus_stock_quantity_non_negative"
  end

  add_foreign_key "skus", "products"
end
