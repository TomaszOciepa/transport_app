class RemoveStatusFromVehicles < ActiveRecord::Migration[8.0]
  def change
    remove_column :vehicles, :status, :integer
  end
end
