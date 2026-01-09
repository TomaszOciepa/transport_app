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
    conversation = WhatsappConversation
      .find_by!(id: params[:conversation_id], user: current_user)

    body = params[:body].to_s.strip
    return head :unprocessable_entity if body.blank?

    to_number =
      conversation.whatsapp_chat_id
        .split("_")
        .reject { |n| n == current_user.phone }
        .first

    conversation.assign_driver_if_possible!(to_number)

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

    head :ok
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



  private

  def resolve_layout
    case current_user.role
    when "admin"      then "admin"
    when "dispatcher" then "dispatcher"
    when "client"     then "client"
    else "application"
    end
  end
end
