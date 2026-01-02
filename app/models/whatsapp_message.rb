class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_conversation

  validates :direction, inclusion: { in: %w[incoming outgoing] }
end
