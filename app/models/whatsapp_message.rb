class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_conversation
  has_one_attached :media

  validates :direction, inclusion: { in: %w[incoming outgoing] }

  after_create_commit :increment_unread_counter, if: :incoming?
  after_create_commit :broadcast_message
  after_create_commit :broadcast_sidebar_reorder
  after_create_commit :broadcast_global_unread_if_needed, if: :incoming?


  def incoming?
    direction == "incoming"
  end

  private

  def increment_unread_counter
    return if conversation_opened?

    whatsapp_conversation.increment!(:unread_count)
  end

  def conversation_opened?
    # value written at the beginning of the request in ApplicationController
    active_id = RequestStore.store[:active_whatsapp_conversation_id]

    active_id.to_i == whatsapp_conversation_id
  end

  # =========================
  # Realtime: Chat Messages
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

    # 1 Delete old conversation entry from list
    Turbo::StreamsChannel.broadcast_remove_to(
      "whatsapp_conversations_#{user_id}",
      target: ActionView::RecordIdentifier.dom_id(conversation)
    )

    # 2 Add it to the top of the list
    Turbo::StreamsChannel.broadcast_prepend_to(
      "whatsapp_conversations_#{user_id}",
      target: "whatsapp_conversation_list",
      partial: "conversations/conversation",
      locals: { conversation: conversation }
    )
  end

  def broadcast_global_unread_if_needed
    whatsapp_conversation.broadcast_global_unread
  end
end
