class AddLastActivityAtToWhatsappGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :whatsapp_groups, :last_activity_at, :datetime
    add_index  :whatsapp_groups, :last_activity_at
  end
end
