class CreateWhatsappMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_messages do |t|
      t.references :whatsapp_group, null: false, foreign_key: true
      t.string :from_number
      t.string :to_number
      t.text :body
      t.boolean :is_from_driver
      t.datetime :timestamp
      t.jsonb :raw_data

      t.timestamps
    end
  end
end
