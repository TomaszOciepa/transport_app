class MakeOrderAndDriverNullableInWhatsappConversations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :whatsapp_conversations, :order_id, true
    change_column_null :whatsapp_conversations, :driver_id, true
  end
end
