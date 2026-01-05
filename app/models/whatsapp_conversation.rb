class WhatsappConversation < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true
  belongs_to :driver, optional: true

  has_many :whatsapp_messages, dependent: :destroy

  validates :whatsapp_chat_id, presence: true
  validates :chat_type, inclusion: { in: %w[private group] }

  after_create_commit :broadcast_sidebar
  after_update_commit :broadcast_sidebar, if: :saved_change_to_last_message_at?

  private

  def broadcast_sidebar
    conversations =
      WhatsappConversation
        .where(user_id: user_id)
        .order(last_message_at: :desc)

    Turbo::StreamsChannel.broadcast_replace_to(
      "whatsapp_conversation_list_#{user_id}",
      target: "whatsapp_conversation_list",
      partial: "conversations/list",
      locals: {
        conversations: conversations,
        user_id: user_id
      }
    )
  end
end
