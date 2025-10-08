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

ActiveRecord::Schema[8.0].define(version: 2025_10_08_084541) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "orders", force: :cascade do |t|
    t.string "pickup_address"
    t.float "pickup_lat"
    t.float "pickup_lon"
    t.string "delivery_address"
    t.float "delivery_lat"
    t.float "delivery_lon"
    t.bigint "vehicle_type_id", null: false
    t.bigint "service_type_id", null: false
    t.datetime "delivery_date"
    t.decimal "price"
    t.float "distance_km"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "pickup_date"
    t.integer "travel_time"
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.string "order_number"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["service_type_id"], name: "index_orders_on_service_type_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["vehicle_type_id"], name: "index_orders_on_vehicle_type_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "multiplier"
  end

  create_table "transport_orders", force: :cascade do |t|
    t.string "pickup_address"
    t.float "pickup_lat"
    t.float "pickup_lon"
    t.string "delivery_address"
    t.float "delivery_lat"
    t.float "delivery_lon"
    t.bigint "vehicle_type_id", null: false
    t.bigint "service_type_id", null: false
    t.datetime "delivery_date"
    t.decimal "price"
    t.float "distance_km"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_type_id"], name: "index_transport_orders_on_service_type_id"
    t.index ["vehicle_type_id"], name: "index_transport_orders_on_vehicle_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicle_types", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.integer "max_speed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price_per_km"
  end

  add_foreign_key "orders", "service_types"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vehicle_types"
  add_foreign_key "transport_orders", "service_types"
  add_foreign_key "transport_orders", "vehicle_types"
end
