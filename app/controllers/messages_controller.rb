class MessagesController < ApplicationController
  before_action :authenticate_user!
  layout :resolve_layout

  def index
    @whatsapp_session = current_user.whatsapp_session

    if @whatsapp_session&.status == "ready"
      @conversations = WhatsappConversation
        .where(user: current_user)
        .order(last_message_at: :desc)
    else
      @conversations = []
    end
  end

  def connect
    Faraday.post(
      "http://localhost:3005/sessions",
      { user_id: current_user.id }.to_json,
      "Content-Type" => "application/json"
    )

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
