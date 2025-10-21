class AddDriverAndVehicleToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :driver, foreign_key: true, index: true, null: true
    add_reference :orders, :vehicle, foreign_key: true, index: true, null: true
  end
end
