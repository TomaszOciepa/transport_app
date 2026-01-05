class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_conversation

  validates :direction, inclusion: { in: %w[incoming outgoing] }

  after_create_commit :broadcast_message
  after_create_commit :broadcast_sidebar_reorder

  private

  # =========================
  # Realtime: wiadomości w czacie
  # =========================
  def broadcast_message
    Turbo::StreamsChannel.broadcast_append_to(
      "whatsapp_messages_#{whatsapp_conversation_id}",
      target: "whatsapp_messages_#{whatsapp_conversation_id}",
      partial: "conversations/message",
      locals: { message: self }
    )
  end

  # =========================
  # Realtime: reorder sidebar
  # =========================
  def broadcast_sidebar_reorder
    conversation = whatsapp_conversation
    user_id      = conversation.user_id

    # 1️⃣ Usuń starą pozycję rozmowy z listy
    Turbo::StreamsChannel.broadcast_remove_to(
      "whatsapp_conversations_#{user_id}",
      target: ActionView::RecordIdentifier.dom_id(conversation)
    )

    # 2️⃣ Dodaj ją na górę listy
    Turbo::StreamsChannel.broadcast_prepend_to(
      "whatsapp_conversations_#{user_id}",
      target: "whatsapp_conversation_list",
      partial: "conversations/conversation",
      locals: { conversation: conversation }
    )
  end
end
