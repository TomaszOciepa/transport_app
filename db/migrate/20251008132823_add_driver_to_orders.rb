class AddDriverToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :driver, null: false, foreign_key: true
  end
end
