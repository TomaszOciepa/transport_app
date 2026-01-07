class WhatsappConversation < ApplicationRecord
  scope :unread, -> { where("unread_count > 0") }
  belongs_to :user
  belongs_to :order, optional: true
  belongs_to :driver, optional: true

  has_many :whatsapp_messages, dependent: :destroy

  validates :whatsapp_chat_id, presence: true
  validates :chat_type, inclusion: { in: %w[private group] }

  after_create_commit :broadcast_sidebar
  after_update_commit :broadcast_sidebar,
  if: -> { saved_change_to_last_message_at? || saved_change_to_unread_count? }

  after_update_commit :broadcast_global_unread,
                    if: :saved_change_to_unread_count?




  def self.total_unread_for(user_id)
    where(user_id: user_id).sum(:unread_count)
  end

  def broadcast_global_unread
    total_unread = WhatsappConversation.total_unread_for(user_id)

    # badge new message in menu
    Turbo::StreamsChannel.broadcast_replace_to(
      "global_unread_#{user_id}",
      target: "global-unread-badge",
      partial: "shared/global_unread_badge",
      locals: { total_unread: total_unread }
    )

  # badge title in the browser
  Turbo::StreamsChannel.broadcast_append_to(
    "global_unread_#{user_id}",
    target: "global-unread-actions",
    partial: "shared/update_page_title",
    locals: { total_unread: total_unread }
  )
  end

  private

  def broadcast_sidebar
    conversations =
      WhatsappConversation
        .where(user_id: user_id)
        .order(last_message_at: :desc)

    Turbo::StreamsChannel.broadcast_replace_to(
      "whatsapp_conversations_#{user_id}",
      target: "whatsapp_conversation_list",
      partial: "conversations/list",
      locals: {
        conversations: conversations,
        user_id: user_id
      }
    )
  end
end
