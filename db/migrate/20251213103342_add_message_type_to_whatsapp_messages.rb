class AddMessageTypeToWhatsappMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :whatsapp_messages, :message_type, :string, default: "text", null: false
  end
end
