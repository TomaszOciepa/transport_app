class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :brand
      t.string :registration_number
      t.references :vehicle_type, null: false, foreign_key: true
      t.integer :status
      t.string :required_license

      t.timestamps
    end
  end
end
