class CreateWhatsappGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_groups do |t|
      t.references :order_vehicle, null: false, foreign_key: true
      t.string :whatsapp_group_id
      t.string :name

      t.timestamps
    end
  end
end
