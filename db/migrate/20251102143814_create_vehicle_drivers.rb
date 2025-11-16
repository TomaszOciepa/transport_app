class CreateVehicleDrivers < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_drivers do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :current

      t.timestamps
    end
  end
end
