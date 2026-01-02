class CreateWhatsappConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :whatsapp_chat_id
      t.string :chat_type
      t.references :order, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.datetime :last_message_at

      t.timestamps
    end
  end
end
