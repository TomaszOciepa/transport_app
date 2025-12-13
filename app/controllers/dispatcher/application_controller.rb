module Dispatcher
    class ApplicationController < ::ApplicationController
      layout "dispatcher"
      before_action :authenticate_user!
      before_action :require_dispatcher
      before_action :set_unread_messages_flag
  
      private
  
      def require_dispatcher
        redirect_to root_path, alert: "Brak dostępu!" unless current_user&.dispatcher?
      end

      def set_unread_messages_flag
        @has_unread_messages = WhatsappMessage.where(read_at: nil).exists?
      end

    end
  end
  