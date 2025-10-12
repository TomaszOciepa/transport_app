class AddLicenseCategoryToDrivers < ActiveRecord::Migration[8.0]
  def change
    # dodaj relację do tabeli license_categories
    add_reference :drivers, :license_category, null: true, foreign_key: true

    # jeśli chcesz od razu wyczyścić starą kolumnę string:
    remove_column :drivers, :license_category, :string
  end
end
