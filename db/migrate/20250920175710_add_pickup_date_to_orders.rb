class AddPickupDateToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :pickup_date, :datetime
  end
end
