class RemoveStatusFromAvailabilities < ActiveRecord::Migration[8.0]
  def change
    remove_column :availabilities, :status, :integer
  end
end
