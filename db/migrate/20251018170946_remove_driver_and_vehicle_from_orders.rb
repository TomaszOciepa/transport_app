class RemoveDriverAndVehicleFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :driver_id, :integer
    remove_column :orders, :vehicle_id, :integer
  end
end
