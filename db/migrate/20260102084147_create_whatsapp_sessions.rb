class CreateWhatsappSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.text :qr_code
      t.string :phone

      t.timestamps
    end
  end
end
