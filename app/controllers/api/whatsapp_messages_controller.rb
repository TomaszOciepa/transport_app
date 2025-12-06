class Api::WhatsappMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # zawsze mamy string w body
    params[:message] ||= ""

    # Znajdź grupę po whatsapp_group_id
    group = WhatsappGroup.find_by(whatsapp_group_id: params[:group_id])
    unless group
      Rails.logger.error("Nie znaleziono WhatsappGroup dla group_id=#{params[:group_id]}")
      return head :unprocessable_entity
    end

    driver_phone = group.order_vehicle.vehicle.current_driver&.phone&.gsub(/\D/, "")

    # Numer nadawcy (participant jeśli wiadomość grupowa)
    sender_number = if params[:raw]&.dig("participant").present?
                      params[:raw]["participant"].gsub(/\D/, "")
                    else
                      params[:from].to_s.gsub(/\D/, "")
                    end

    # Sprawdzenie, czy wiadomość pochodzi od bota
    bot_number_serialized = params[:raw]&.dig("fromMe") ? params[:from].to_s.gsub(/\D/, "") : nil

    # --- NOWA LOGIKA ---
    is_driver = false
    if bot_number_serialized.nil? || sender_number != bot_number_serialized
      is_driver = driver_phone.present? && driver_phone == sender_number
    end

    message = WhatsappMessage.new(
      whatsapp_group: group,
      from_number: params[:from],
      to_number: params[:to],
      body: params[:message],
      is_from_driver: is_driver,
      timestamp: Time.at(params[:timestamp].to_i),
      raw_data: params[:raw]
    )

    if message.save
      render json: { ok: true }
    else
      Rails.logger.error("Nie udało się zapisać wiadomości: #{message.errors.full_messages.join(', ')}")
      render json: { error: message.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
