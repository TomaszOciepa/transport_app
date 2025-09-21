class AddPricePerKmToVehicleTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicle_types, :price_per_km, :decimal
  end
end
