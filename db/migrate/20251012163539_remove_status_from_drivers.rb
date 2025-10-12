class RemoveStatusFromDrivers < ActiveRecord::Migration[8.0]
  def change
    remove_column :drivers, :status, :integer
  end
end
