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

ActiveRecord::Schema[8.0].define(version: 2025_07_28_092500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "car_images", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.text "image_data"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_car_images_on_car_id"
  end

  create_table "cars", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "location"
    t.decimal "price"
    t.string "transmission"
    t.string "category"
    t.string "fuel_type"
    t.string "engine_capacity"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_air_conditioner", default: false
    t.integer "horsepower"
    t.string "drive"
    t.jsonb "custom_fields"
    t.boolean "is_calendar", default: false
    t.index ["user_id"], name: "index_cars_on_user_id"
  end

  create_table "company_logos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "image_data"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_company_logos_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "car_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_favorites_on_car_id"
    t.index ["user_id", "car_id"], name: "index_favorites_on_user_id_and_car_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.integer "role"
    t.string "company_name"
    t.string "phone"
    t.string "whatsapp"
    t.string "telegram"
    t.string "instagram"
    t.jsonb "phone_1"
    t.jsonb "phone_2"
    t.string "website"
    t.text "about"
    t.string "address"
    t.text "company_avatar_data"
    t.string "region"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "car_images", "cars"
  add_foreign_key "cars", "users"
  add_foreign_key "company_logos", "users"
  add_foreign_key "favorites", "cars"
  add_foreign_key "favorites", "users"
end
