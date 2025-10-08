module Admin
    class ApplicationController < ::ApplicationController
      layout "admin"
      before_action :authenticate_user!
      before_action :require_admin
  
      private
  
      def require_admin
        redirect_to root_path, alert: "Brak dostępu!" unless current_user&.admin?
      end
    end
  end
  