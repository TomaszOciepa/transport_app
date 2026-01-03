class MessagesController < ApplicationController
  before_action :authenticate_user!
  layout :resolve_layout

  def index
    @whatsapp_session = current_user.whatsapp_session
  
    if @whatsapp_session&.status == "ready"
      @conversations =
        WhatsappConversation
          .where(user: current_user)
          .order(last_message_at: :desc)
  
      @active_conversation = @conversations.first
  
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
  

  def connect
    session =
      current_user.whatsapp_session ||
      current_user.create_whatsapp_session!(status: "disconnected")
  
   #show spinner
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
