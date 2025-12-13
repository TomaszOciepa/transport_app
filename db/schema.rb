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

ActiveRecord::Schema[8.0].define(version: 2025_12_12_194754) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "availableable_type", null: false
    t.bigint "availableable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availableable_type", "availableable_id"], name: "idx_on_availableable_type_availableable_id_5acfd8ecd9"
    t.index ["availableable_type", "availableable_id"], name: "index_availabilities_on_availableable"
    t.index ["start_time", "end_time"], name: "index_availabilities_on_start_time_and_end_time"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.integer "birth_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "license_category_id"
    t.index ["license_category_id"], name: "index_drivers_on_license_category_id"
  end

  create_table "license_categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "max_hours_per_day", default: 8, null: false
    t.integer "max_hours_per_week", default: 40, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_license_categories_on_name", unique: true
  end

  create_table "license_categories_vehicle_types", id: false, force: :cascade do |t|
    t.bigint "vehicle_type_id", null: false
    t.bigint "license_category_id", null: false
    t.index ["license_category_id", "vehicle_type_id"], name: "index_license_category_vehicle_type"
    t.index ["vehicle_type_id", "license_category_id"], name: "index_vehicle_type_license_category", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "order_conversation_id"
    t.string "sender_type"
    t.string "sender_phone"
    t.string "direction"
    t.text "body"
    t.string "wa_message_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_conversation_id"], name: "index_messages_on_order_conversation_id"
  end

  create_table "order_conversations", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "wa_thread_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_conversations_on_order_id"
  end

  create_table "order_vehicles", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "vehicle_id", null: false
    t.bigint "user_id", null: false
    t.boolean "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_vehicles_on_order_id"
    t.index ["user_id"], name: "index_order_vehicles_on_user_id"
    t.index ["vehicle_id"], name: "index_order_vehicles_on_vehicle_id"
  end

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

  create_table "vehicle_drivers", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.bigint "driver_id", null: false
    t.bigint "user_id", null: false
    t.boolean "current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_vehicle_drivers_on_driver_id"
    t.index ["user_id"], name: "index_vehicle_drivers_on_user_id"
    t.index ["vehicle_id"], name: "index_vehicle_drivers_on_vehicle_id"
  end

  create_table "vehicle_types", force: :cascade do |t|
    t.string "name"
    t.integer "max_speed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price_per_km"
    t.integer "capacity_weight"
    t.integer "capacity_volume"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "brand"
    t.string "registration_number"
    t.bigint "vehicle_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_type_id"], name: "index_vehicles_on_vehicle_type_id"
  end

  create_table "whatsapp_groups", force: :cascade do |t|
    t.string "whatsapp_group_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_id"
    t.bigint "driver_id"
    t.boolean "order_sent", default: false, null: false
    t.datetime "last_activity_at"
    t.index ["driver_id"], name: "index_whatsapp_groups_on_driver_id"
    t.index ["last_activity_at"], name: "index_whatsapp_groups_on_last_activity_at"
    t.index ["order_id", "driver_id"], name: "index_whatsapp_groups_on_order_id_and_driver_id", unique: true
    t.index ["order_id"], name: "index_whatsapp_groups_on_order_id"
  end

  create_table "whatsapp_messages", force: :cascade do |t|
    t.bigint "whatsapp_group_id", null: false
    t.string "from_number"
    t.string "to_number"
    t.text "body"
    t.boolean "is_from_driver"
    t.datetime "timestamp"
    t.jsonb "raw_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.index ["whatsapp_group_id"], name: "index_whatsapp_messages_on_whatsapp_group_id"
  end

  add_foreign_key "drivers", "license_categories"
  add_foreign_key "messages", "order_conversations"
  add_foreign_key "order_conversations", "orders"
  add_foreign_key "order_vehicles", "orders"
  add_foreign_key "order_vehicles", "users"
  add_foreign_key "order_vehicles", "vehicles"
  add_foreign_key "orders", "service_types"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vehicle_types"
  add_foreign_key "transport_orders", "service_types"
  add_foreign_key "transport_orders", "vehicle_types"
  add_foreign_key "vehicle_drivers", "drivers"
  add_foreign_key "vehicle_drivers", "users"
  add_foreign_key "vehicle_drivers", "vehicles"
  add_foreign_key "vehicles", "vehicle_types"
  add_foreign_key "whatsapp_groups", "drivers"
  add_foreign_key "whatsapp_groups", "orders"
  add_foreign_key "whatsapp_messages", "whatsapp_groups"
end
