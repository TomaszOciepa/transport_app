class Api::WhatsappMessagesController < ApplicationController
    skip_before_action :verify_authenticity_token

    # POST /api/whatsapp_messages
    def create
      user = User.find(params[:user_id])

      # Normalize phone numbers
      from_number = params[:from]
      owner_phone = user.phone

      # Find or create PRIVATE conversation
      conversation = WhatsappConversation.find_or_create_by!(
        user: user,
        chat_type: "private",
        whatsapp_chat_id: private_chat_id(user.phone, from_number)
      )

      message = conversation.whatsapp_messages.create!(
        direction: incoming_or_outgoing?(from_number, owner_phone),
        from_number: from_number,
        to_number: owner_phone,
        body: params[:message],
        message_type: "text",
        raw_payload: params.to_json,
        sent_at: Time.at(params[:timestamp])
      )

      conversation.update!(last_message_at: message.sent_at)

      head :ok
    end

    private

    # Deterministic ID for 1-to-1 chat
    def private_chat_id(a, b)
      [a, b].sort.join("_")
    end

    def incoming_or_outgoing?(from, owner_phone)
      from == owner_phone ? "outgoing" : "incoming"
    end
end
