class CreateDrivers < ActiveRecord::Migration[8.0]
  def change
    create_table :drivers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :license_category
      t.integer :birth_year
      t.time :available_from
      t.time :available_to
      t.integer :status

      t.timestamps
    end
  end
end
