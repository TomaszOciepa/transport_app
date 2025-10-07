module Dispatcher
    class ApplicationController < ::ApplicationController
      layout "dispatcher"
      before_action :authenticate_user!
      before_action :require_dispatcher
  
      private
  
      def require_dispatcher
        redirect_to root_path, alert: "Brak dostępu!" unless current_user&.dispatcher?
      end
    end
  end
  