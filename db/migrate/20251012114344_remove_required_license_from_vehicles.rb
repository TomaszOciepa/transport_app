class RemoveRequiredLicenseFromVehicles < ActiveRecord::Migration[8.0]
  def change
    remove_column :vehicles, :required_license, :string
  end
end
