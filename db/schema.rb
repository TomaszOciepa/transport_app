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

ActiveRecord::Schema[8.0].define(version: 2025_09_19_184408) do
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
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_type_id"], name: "index_orders_on_service_type_id"
    t.index ["vehicle_type_id"], name: "index_orders_on_vehicle_type_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicle_types", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.integer "max_speed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "orders", "service_types"
  add_foreign_key "orders", "vehicle_types"
end
