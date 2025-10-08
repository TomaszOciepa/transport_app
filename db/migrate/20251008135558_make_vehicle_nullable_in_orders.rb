class MakeVehicleNullableInOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :vehicle_id, true
  end
end
