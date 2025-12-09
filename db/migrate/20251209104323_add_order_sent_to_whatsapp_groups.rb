class AddOrderSentToWhatsappGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :whatsapp_groups, :order_sent, :boolean, default: false, null: false
  end
end
