class CreateVehicleTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_types do |t|
      t.string :name
      t.integer :capacity
      t.integer :max_speed

      t.timestamps
    end
  end
end
