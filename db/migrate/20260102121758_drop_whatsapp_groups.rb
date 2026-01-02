class DropWhatsappGroups < ActiveRecord::Migration[8.0]
  def change
    drop_table :whatsapp_groups
  end
end
