class DropOrderDriversTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :order_drivers
  end
end
