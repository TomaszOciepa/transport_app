class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :pickup_address
      t.float :pickup_lat
      t.float :pickup_lon
      t.string :delivery_address
      t.float :delivery_lat
      t.float :delivery_lon
      t.references :vehicle_type, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.datetime :delivery_date
      t.decimal :price
      t.float :distance_km
      t.integer :status

      t.timestamps
    end
  end
end
