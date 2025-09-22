class AddTravelTimeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :travel_time, :integer
  end
end
