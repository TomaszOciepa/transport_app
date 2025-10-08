module Client
    class ApplicationController < ::ApplicationController
      layout "client"
      before_action :authenticate_user!
      before_action :require_client
  
      private
  
      def require_client
        redirect_to root_path, alert: "Brak dostępu!" unless current_user&.client?
      end
    end
  end
  