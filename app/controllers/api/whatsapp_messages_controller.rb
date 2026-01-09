class Api::WhatsappMessagesController < ApplicationController
    skip_before_action :verify_authenticity_token

    # POST /api/whatsapp_messages
    def create
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

      message = conversation.whatsapp_messages.create!(
        direction: direction,
        from_number: from_number,
        to_number: to_number,
        body: params[:message],
        message_type: "text",
        raw_payload: params.to_json,
        sent_at: Time.at(params[:timestamp].to_i)
      )

      conversation.update!(last_message_at: message.sent_at)

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
end
