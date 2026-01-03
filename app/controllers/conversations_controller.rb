class ConversationsController < ApplicationController
    before_action :authenticate_user!
  
    def index
      @conversations =
        WhatsappConversation
          .where(user: current_user)
          .order(last_message_at: :desc)
    end
  
    def show
      @conversation =
        WhatsappConversation
          .where(user: current_user)
          .find(params[:id])
  
      @messages =
        @conversation.whatsapp_messages.order(:created_at)
    end
  end
  