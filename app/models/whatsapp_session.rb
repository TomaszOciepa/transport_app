class WhatsappSession < ApplicationRecord
  belongs_to :user

  after_update_commit :broadcast_session_changes
  after_update_commit :broadcast_conversations_if_ready

  private

  def broadcast_session_changes
    Rails.logger.info "BROADCAST WhatsappSession #{id} STATUS=#{status}"

    broadcast_replace_to(
      "whatsapp_session_#{user_id}",
      target: "whatsapp_session",
      partial: "messages/whatsapp_session",
      locals: { whatsapp_session: self }
    )
  end

  def broadcast_conversations_if_ready
    return unless status == "ready"

    Rails.logger.info "BROADCAST Conversations for user #{user_id}"

    conversations =
      WhatsappConversation
        .where(user_id: user_id)
        .order(last_message_at: :desc)

    active_conversation = conversations.first

    messages =
      active_conversation ?
        active_conversation.whatsapp_messages.order(:created_at) :
        []

    broadcast_replace_to(
      "whatsapp_conversations_#{user_id}",
      target: "whatsapp_conversations",
      partial: "messages/whatsapp_conversations",
      locals: {
        whatsapp_session: self,
        conversations: conversations,
        active_conversation: active_conversation,
        messages: messages
      }
    )
  end
end
