class WhatsappSession < ApplicationRecord
  belongs_to :user
  after_update_commit :broadcast_changes

  private

  def broadcast_changes
    Rails.logger.info "🔥 BROADCAST WhatsappSession #{id} STATUS=#{status}"
    broadcast_replace_to(
      "whatsapp_session_#{user_id}",
      target: "whatsapp_session",
      partial: "messages/whatsapp_session",
      locals: { whatsapp_session: self }
    )
  end
end
