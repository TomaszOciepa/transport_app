class RemoveDriverAndVehicleFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_reference :orders, :driver, null: false, foreign_key: true
    remove_reference :orders, :vehicle, null: false, foreign_key: true
  end
end
