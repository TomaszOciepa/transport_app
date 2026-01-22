class MessagesController < ApplicationController
  before_action :authenticate_user!
  layout :resolve_layout

  def index
    @whatsapp_session = current_user.whatsapp_session

    if params[:conversation_id].present?
      session[:active_whatsapp_conversation_id] = params[:conversation_id].to_i
    end

    if @whatsapp_session&.status == "ready"
      @conversations =
        WhatsappConversation
          .where(user: current_user)
          .order(last_message_at: :desc)

      @active_conversation =
        @conversations.find { |c| c.id == session[:active_whatsapp_conversation_id] } ||
        @conversations.first

      @messages =
        @active_conversation ?
          @active_conversation.whatsapp_messages.order(:created_at) :
          []
    else
      @conversations = []
      @active_conversation = nil
      @messages = []
    end
  end

  def mark_as_read
    conversation = WhatsappConversation
      .find_by(id: params[:conversation_id], user_id: current_user.id)

    return head :not_found unless conversation

    conversation.update!(unread_count: 0)

    head :ok
  end

  def send_message
    conversation = WhatsappConversation.find_by!(
      id: params[:conversation_id],
      user: current_user
    )

    body = params[:body].to_s.strip
    file = params[:file]

    return head :unprocessable_entity if body.blank? && file.blank?

    return send_media(conversation, file, body) if file.present?

    if conversation.chat_type == "group"
      send_group_message(conversation, body)
    else
      send_private_message(conversation, body)
    end
  end

  def send_private_message(conversation, body)
    to_number =
      conversation.whatsapp_chat_id
        .split("_")
        .reject { |n| n == current_user.phone }
        .first

    response = Faraday.post(
      "http://localhost:3005/send",
      {
        user_id: current_user.id,
        phone: to_number,
        message: body
      }.to_json,
      "Content-Type" => "application/json"
    )

    return head :service_unavailable unless response.success?

    message = conversation.whatsapp_messages.create!(
      direction: "outgoing",
      from_number: current_user.phone,
      to_number: to_number,
      body: body,
      message_type: "text",
      sent_at: Time.current
    )

    conversation.update!(
      last_message_at: message.sent_at,
      last_message_preview: body.truncate(60)
    )

    head :ok
  end

  def send_group_message(conversation, body)
    response = Faraday.post(
      "http://localhost:3005/groups/send",
      {
        user_id: current_user.id,
        group_id: conversation.whatsapp_chat_id,
        message: body
      }.to_json,
      "Content-Type" => "application/json"
    )

    return head :service_unavailable unless response.success?

    message = conversation.whatsapp_messages.create!(
      direction: "outgoing",
      from_number: current_user.phone,
      to_number: conversation.whatsapp_chat_id,
      body: body,
      message_type: "text",
      sent_at: Time.current
    )

    conversation.update!(
      last_message_at: message.sent_at,
      last_message_preview: body.truncate(60)
    )

    head :ok
  end


  def send_order_details
    conversation = WhatsappConversation.find_by!(
      id: params[:conversation_id],
      user: current_user,
      chat_type: "group"
    )

    order = Order.find(conversation.order_id)

    pickup_map_url =
      "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(order.pickup_address)}"

    delivery_map_url =
      "https://www.google.com/maps/search/?api=1&query=#{CGI.escape(order.delivery_address)}"

    body = <<~MSG.strip
      📦 Zamówienie numer: #{order.order_number}

      📍 Odbiór:
      #{order.pickup_address}
      🕒 #{order.pickup_date.strftime("%Y-%m-%d %H:%M")}
      🗺️ Mapa: #{pickup_map_url}

      📦 Dostawa:
      #{order.delivery_address}
      🕒 #{order.delivery_date.strftime("%Y-%m-%d %H:%M")}
      🗺️ Mapa: #{delivery_map_url}
    MSG

    # 🔁 wysyłka do WhatsApp (Node)
    response = Faraday.post(
      "http://localhost:3005/groups/send",
      {
        user_id: current_user.id,
        group_id: conversation.whatsapp_chat_id,
        message: body
      }.to_json,
      "Content-Type" => "application/json"
    )

    unless response.success?
      Rails.logger.error("[WHATSAPP ORDER DETAILS ERROR] #{response.body}")
      return head :service_unavailable
    end

    # 💾 zapis wiadomości w DB (jak normalny chat)
    message = conversation.whatsapp_messages.create!(
      direction: "outgoing",
      from_number: current_user.phone,
      to_number: conversation.whatsapp_chat_id,
      body: body,
      message_type: "text",
      sent_at: Time.current
    )

    conversation.update!(
      last_message_at: message.sent_at,
      last_message_preview: body.truncate(60)
    )

    head :ok
  end

  def send_media(conversation, file, caption)
    base64   = Base64.strict_encode64(file.read)
    mimetype = file.content_type
    filename = file.original_filename

    if conversation.chat_type == "group"
      response = Faraday.post(
        "http://localhost:3005/groups/send_media",
        {
          user_id: current_user.id,
          group_id: conversation.whatsapp_chat_id,
          base64: base64,
          mimetype: mimetype,
          filename: filename,
          caption: caption
        }.to_json,
        "Content-Type" => "application/json"
      )
      to_number = conversation.whatsapp_chat_id
    else
      to_number =
        conversation.whatsapp_chat_id
          .split("_")
          .reject { |n| n == current_user.phone }
          .first

      response = Faraday.post(
        "http://localhost:3005/send_media",
        {
          user_id: current_user.id,
          phone: to_number,
          base64: base64,
          mimetype: mimetype,
          filename: filename,
          caption: caption
        }.to_json,
        "Content-Type" => "application/json"
      )
    end

    unless response.success?
      Rails.logger.error("[WHATSAPP MEDIA SEND ERROR] #{response.body}")
      return head :service_unavailable
    end

    # zapis w DB
    message = conversation.whatsapp_messages.create!(
      direction: "outgoing",
      from_number: current_user.phone,
      to_number: to_number,
      body: caption,
      message_type: "media",
      sent_at: Time.current
    )

    message.media.attach(file)

    preview = caption.present? ? caption.truncate(60) : "📎 Załącznik"

    conversation.update!(
      last_message_at: message.sent_at,
      last_message_preview: preview
    )

    head :ok
  ensure
    file.rewind if file.respond_to?(:rewind)
  end


  def connect
    session =
      current_user.whatsapp_session ||
      current_user.create_whatsapp_session!(status: "disconnected")

    # show spinner
    session.update!(status: "pending", qr_code: nil)

    # watchdog
    WhatsappConnectTimeoutJob.set(wait: 60.seconds).perform_later(session.id)

    # API call (no rescue!)
    response =
      Faraday.post(
        "http://localhost:3000/api/whatsapp_session/connect",
        { user_id: current_user.id }.to_json,
        "Content-Type" => "application/json"
      )

    # UX feedback
    if response.status == 503
      flash[:alert] =
        "WhatsApp service is currently unavailable. Please try again later."
    end

    redirect_to messages_path
  end


  def disconnect
    Faraday.post(
    "http://localhost:3000/api/whatsapp_session/disconnect",
    { user_id: current_user.id }.to_json,
    "Content-Type" => "application/json"
  )

  redirect_to messages_path, notice: "WhatsApp disconnecting…"
  end

  def ensure_driver_conversation
    driver = Driver.find(params[:driver_id])

    chat_id =
      [ current_user.phone, driver.phone ]
        .sort
        .join("_")

      conversation =
        WhatsappConversation.find_or_create_by!(
          user: current_user,
          chat_type: "private",
          whatsapp_chat_id: chat_id
        ) do |c|
          c.driver = driver
        end


    # przypisz kierowcę (jeśli jeszcze nie)
    if conversation.driver_id != driver.id
      conversation.update!(driver: driver)
    end

    render json: { conversation_id: conversation.id }
  end

  def delete_conversation
    conversation =
      WhatsappConversation.find_by!(
        id: params[:conversation_id],
        user: current_user
      )

    conversation.destroy!

    # jeśli usunięto aktualnie otwarty czat
    if session[:active_whatsapp_conversation_id] == conversation.id
      session.delete(:active_whatsapp_conversation_id)
    end

    head :ok
  end


  private

  def resolve_layout
    case current_user.role
    when "admin"      then "admin"
    when "dispatcher" then "dispatcher"
    when "client"     then "client"
    else "application"
    end
  end

  def build_order_details_message(order)
    <<~MSG.strip
      📦 *Zamówienie numer:* #{order.order_number}

      📍 *Odbiór:*
      #{order.pickup_address}
      🕒 #{order.pickup_date.strftime("%Y-%m-%d %H:%M")}

      🚚 *Dostawa:*
      #{order.delivery_address}
      🕒 #{order.delivery_date.strftime("%Y-%m-%d %H:%M")}
    MSG
  end
end
