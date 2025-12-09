class UpdateWhatsappGroupsStructure < ActiveRecord::Migration[8.0]
  def change
    remove_column :whatsapp_groups, :order_vehicle_id, :integer

    add_reference :whatsapp_groups, :order, foreign_key: true
    add_reference :whatsapp_groups, :driver, foreign_key: true

    add_index :whatsapp_groups, [:order_id, :driver_id], unique: true
  end
end
