class ChangeStatusInOrders < ActiveRecord::Migration[8.0]
  def change
    # usuń stare pole string
    remove_column :orders, :status, :string

    # dodaj nowe pole integer z domyślną wartością 0 (Pending)
    add_column :orders, :status, :integer, default: 0, null: false
  end
end
