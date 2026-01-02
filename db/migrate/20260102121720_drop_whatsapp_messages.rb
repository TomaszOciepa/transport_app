class DropWhatsappMessages < ActiveRecord::Migration[8.0]
  def change
    drop_table :whatsapp_messages
  end
end
