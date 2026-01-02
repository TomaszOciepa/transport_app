class WhatsappConversation < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true
  belongs_to :driver, optional: true

  has_many :whatsapp_messages, dependent: :destroy

  validates :whatsapp_chat_id, presence: true
  validates :chat_type, inclusion: { in: %w[private group] }
end
