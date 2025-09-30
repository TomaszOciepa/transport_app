class AddMultiplierToServiceTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :service_types, :multiplier, :decimal
  end
end
