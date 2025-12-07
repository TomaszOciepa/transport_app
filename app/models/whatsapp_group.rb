class WhatsappGroup < ApplicationRecord
  belongs_to :order
  belongs_to :driver

  has_many :whatsapp_messages, dependent: :destroy
end

