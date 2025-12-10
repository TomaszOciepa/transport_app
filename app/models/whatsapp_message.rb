class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_group

  after_create_commit do
    broadcast_append_to "chat_channel_#{whatsapp_group.id}", target: "messagesBox", partial: "dispatcher/messages/message", locals: { msg: self }
  end
end


