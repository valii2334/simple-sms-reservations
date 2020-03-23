# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_09_141803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "unit_of_time"
    t.integer "customers_per_unit_of_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "closed_saturday", default: true, null: false
    t.boolean "closed_sunday", default: true, null: false
    t.boolean "temporarily_closed", default: false
    t.datetime "opening_time", null: false
    t.datetime "closing_time", null: false
    t.integer "user_id"
    t.datetime "opening_time_saturday"
    t.datetime "closing_time_saturday"
    t.datetime "opening_time_sunday"
    t.datetime "closing_time_sunday"
    t.string "reservation_message"
    t.string "temporarily_closed_message"
    t.string "date_format", default: "DMY", null: false
    t.index ["code"], name: "index_companies_on_code", unique: true
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "reservations", force: :cascade do |t|
    t.string "phone_number"
    t.integer "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "reservation_date"
    t.string "details"
    t.index ["company_id", "phone_number", "reservation_date"], name: "reservation_unique_index", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
