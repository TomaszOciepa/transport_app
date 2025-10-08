class ChangeDriverIdOnOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :driver_id, true
  end
end
