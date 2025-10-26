class CreateOrderVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :order_vehicles do |t|
      t.references :order, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true 
      t.boolean :current

      t.timestamps
    end
  end
end
