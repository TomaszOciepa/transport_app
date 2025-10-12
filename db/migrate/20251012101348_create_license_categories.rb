class CreateLicenseCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :license_categories do |t|
      t.string :name, null: false
      t.integer :max_hours_per_day, null: false, default: 8
      t.integer :max_hours_per_week, null: false, default: 40

      t.timestamps
    end

    add_index :license_categories, :name, unique: true
  end
end
