class AddStatusToDrivers < ActiveRecord::Migration[8.0]
  def change
    add_column :drivers, :status, :integer
  end
end
