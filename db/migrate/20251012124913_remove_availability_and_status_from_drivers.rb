class RemoveAvailabilityAndStatusFromDrivers < ActiveRecord::Migration[8.0]
  def change
    remove_column :drivers, :available_from, :datetime
    remove_column :drivers, :available_to, :datetime
    remove_column :drivers, :status, :string
  end
end
