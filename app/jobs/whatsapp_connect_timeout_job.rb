class WhatsappConnectTimeoutJob < ApplicationJob
  queue_as :default

  def perform(whatsapp_session_id)
    session = WhatsappSession.find_by(id: whatsapp_session_id)
    return unless session

    if session.status == "pending"
      session.update!(status: "disconnected")

      Rails.logger.warn(
        "WhatsApp connect timeout for user #{session.user_id}"
      )
    end
  end
end
