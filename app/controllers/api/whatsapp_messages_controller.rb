# app/controllers/api/whatsapp_messages_controller.rb
class Api::WhatsappMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    params[:message] ||= ""

    group = WhatsappGroup.find_by(whatsapp_group_id: params[:group_id])
    unless group
      Rails.logger.error("Nie znaleziono WhatsappGroup dla group_id=#{params[:group_id]}")
      return head :unprocessable_entity
    end

    # Numer nadawcy z Node.js
    participant_jid = params[:raw]&.dig("participant") || params[:from]

    # Nie sprawdzamy już driver.current_driver – zapisujemy wszystko
    is_driver = params[:raw]&.dig("fromMe") == false && participant_jid.present?

    message = WhatsappMessage.new(
      whatsapp_group: group,
      from_number: participant_jid,
      to_number: params[:to],
      body: params[:message],
      is_from_driver: is_driver,
      timestamp: Time.at(params[:timestamp].to_i),
      raw_data: params[:raw]
    )

    if message.save
      Rails.logger.info("💾 Wiadomość zapisana w Rails: #{message.body} | from: #{message.from_number}")
      render json: { ok: true }
    else
      Rails.logger.error("Nie udało się zapisać wiadomości: #{message.errors.full_messages.join(', ')}")
      render json: { error: message.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
