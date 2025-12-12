class Api::WhatsappMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    params[:message] ||= ""

    group = WhatsappGroup.find_by(whatsapp_group_id: params[:group_id])
    unless group
      Rails.logger.error(
        "Nie znaleziono WhatsappGroup dla group_id=#{params[:group_id]}"
      )
      return head :unprocessable_entity
    end

    # --- sender z Node.js / WhatsApp ---
    participant_jid =
      params.dig(:raw, "participant") || params[:from]

    is_driver =
      params.dig(:raw, "fromMe") == false && participant_jid.present?

    message = WhatsappMessage.new(
      whatsapp_group: group,
      from_number:    participant_jid,
      to_number:      params[:to],
      body:           params[:message],
      is_from_driver: is_driver,
      timestamp:      Time.at(params[:timestamp].to_i),
      raw_data:       params[:raw],
      read_at:        nil # ⬅ przychodzące = NIEPRZECZYTANE
    )

    if message.save
      Rails.logger.info(
        "💾 Wiadomość zapisana: #{message.body} | group=#{group.id}"
      )

      Rails.logger.info("API_INCOMING: group=#{group.id} msg_id=#{message.id}")
      Rails.logger.info("BROADCAST_CHAT: stream=chat_channel_#{group.id} target=messages msg_id=#{message.id}")

      # =========================
      # 🔹 PRAWA KOLUMNA (CHAT)
      # =========================
      Turbo::StreamsChannel.broadcast_append_to(
        "chat_channel_#{group.id}",
        target: "messages",
        partial: "dispatcher/messages/message",
        locals: { msg: message }
      )

            # =========================
        # 🔔 LEWA KOLUMNA (BADGE / READ)
        # =========================
        active_group_id = session[:active_whatsapp_group_id]

        if active_group_id.present? && active_group_id.to_i == group.id
          # 🟢 użytkownik JEST w tym czacie → od razu przeczytane
          message.update_column(:read_at, Time.current)

          Turbo::StreamsChannel.broadcast_replace_to(
            "chat_notifications",
            target: "chat_group_#{group.id}",
            partial: "dispatcher/messages/chat_row",
            locals: {
              group:  group.reload,
              active: true
            }
          )
        else
          # 🔴 użytkownik NIE jest w tym czacie → badge rośnie
          Turbo::StreamsChannel.broadcast_replace_to(
            "chat_notifications",
            target: "chat_group_#{group.id}",
            partial: "dispatcher/messages/chat_row",
            locals: {
              group:  group.reload,
              active: false
            }
          )
        end


      render json: { ok: true }
    else
      Rails.logger.error(
        "❌ Nie udało się zapisać wiadomości: #{message.errors.full_messages.join(', ')}"
      )
      render json: { error: message.errors.full_messages },
             status: :unprocessable_entity
    end
  end
end
