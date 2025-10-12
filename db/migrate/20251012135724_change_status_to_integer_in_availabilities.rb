class ChangeStatusToIntegerInAvailabilities < ActiveRecord::Migration[8.0]
  def change
    remove_column :availabilities, :status, :string
    add_column :availabilities, :status, :integer, default: 0, null: false
  end
end
