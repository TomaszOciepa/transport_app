class RemoveStatusFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :status, :integer
  end
end
