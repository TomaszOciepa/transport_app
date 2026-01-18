class AddGroupNameToWhatsappConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :whatsapp_conversations, :group_name, :string
  end
end
