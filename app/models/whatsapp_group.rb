class WhatsappGroup < ApplicationRecord
  belongs_to :order_vehicle
  has_many :whatsapp_messages
end

