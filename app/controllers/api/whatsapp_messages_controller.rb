class Api::WhatsappMessagesController < ApplicationController
    skip_before_action :verify_authenticity_token
    require "base64"

    # POST /api/whatsapp_messages
    def create
      if params[:chat_type] == "group"
        conversation =
          WhatsappConversation.find_by!(
            whatsapp_chat_id: params[:group_id],
            chat_type: "group"
          )

        has_media = params[:media].present?

        message = conversation.whatsapp_messages.create!(
          direction: params[:direction].presence || "incoming",
          from_number: params[:from],
          to_number: params[:group_id],
          body: params[:message],
          message_type: has_media ? "media" : "text",
          raw_payload: params.to_json,
          sent_at: Time.at(params[:timestamp].to_i)
        )

        attach_media!(message)
        attach_media_to_order(message)

        preview =
          message.body.present? ? message.body.truncate(60) : "📎 Załącznik"

        conversation.update!(
          last_message_at: message.sent_at,
          last_message_preview: preview
          # UWAGA: unread_count masz w modelu WhatsappMessage (after_create_commit)
          # więc tutaj NIE zwiększaj ręcznie, bo zrobisz podwójnie.
        )

        return head :ok
      end

      user = User.find(params[:user_id])

      owner_phone = user.phone

      direction =
        params[:direction].presence ||
        incoming_or_outgoing?(params[:from], owner_phone)

      from_number =
        direction == "outgoing" ? owner_phone : params[:from]

      to_number =
        direction == "outgoing" ? params[:to] : owner_phone

      chat_partner =
        direction == "outgoing" ? to_number : from_number

      conversation = WhatsappConversation.find_or_create_by!(
        user: user,
        chat_type: "private",
        whatsapp_chat_id: private_chat_id(owner_phone, chat_partner)
      )

      conversation.assign_driver_if_possible!(chat_partner)

      has_media = params[:media].present?

      message = conversation.whatsapp_messages.create!(
        direction: direction,
        from_number: from_number,
        to_number: to_number,
        body: params[:message],
        message_type: has_media ? "media" : "text",
        raw_payload: params.to_json,
        sent_at: Time.at(params[:timestamp].to_i)
      )

      attach_media!(message)
      attach_media_to_order(message)

      preview =
        message.body.present? ? message.body.truncate(60) : "📎 Załącznik"

      conversation.update!(
        last_message_at: message.sent_at,
        last_message_preview: preview
      )

      head :ok
    end

    private

    # Deterministic ID for 1-to-1 chat
    def private_chat_id(a, b)
      [ a, b ].sort.join("_")
    end

    def incoming_or_outgoing?(from, owner_phone)
      from == owner_phone ? "outgoing" : "incoming"
    end

    def attach_media!(message)
      return unless params[:media].present?

      media = params[:media].to_unsafe_h
      data = media["data"]
      return if data.blank?

      decoded = Base64.decode64(data)

      filename = media["filename"].presence || "file"
      mimetype = media["mimetype"].presence || "application/octet-stream"
      kind     = media["type"].presence

      message.update!(media_kind: kind) if message.respond_to?(:media_kind)

      message.media.attach(
        io: StringIO.new(decoded),
        filename: filename,
        content_type: mimetype
      )
    end

    def attach_media_to_order(message)
      return unless message.media.attached?

      conversation = message.whatsapp_conversation
      return unless conversation&.order_id.present?

      order = conversation.order
      order.documents.attach(message.media.blob)
    end
end
