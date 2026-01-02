class CreateWhatsappMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_messages do |t|
      t.references :whatsapp_conversation, null: false, foreign_key: true
      t.string :direction
      t.string :from_number
      t.string :to_number
      t.text :body
      t.string :message_type
      t.jsonb :raw_payload
      t.datetime :sent_at
      t.datetime :read_at

      t.timestamps
    end
  end
end
