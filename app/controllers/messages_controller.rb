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

    # set pending
    # this will call after_update_commit
    # Turbo will immediately show the spinner
    session.update!(status: "pending", qr_code: nil)

    # WATCHDOG – in 60 seconds we check if anything has changed
    WhatsappConnectTimeoutJob.set(wait: 60.seconds).perform_later(session.id)
   
  
    begin
      Faraday.post(
        "http://localhost:3005/sessions",
        { user_id: current_user.id }.to_json,
        "Content-Type" => "application/json"
      )
    rescue Faraday::ConnectionFailed, Errno::ECONNREFUSED => e
      Rails.logger.error "WhatsApp Node unavailable: #{e.message}"
  
     # we are withdrawing the status because we are not waiting for anything anymore
      session.update!(status: "disconnected")
  
      redirect_to messages_path,
        alert: "WhatsApp service is currently unavailable. Please try again later."
      return
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
