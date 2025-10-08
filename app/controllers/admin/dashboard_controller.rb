module Admin
    class DashboardController < ApplicationController
      def index; end
        
        def settings
            @page_title = "Ustawienia w budowie"
            render "coming_soon" 
        end

        def reports
            @page_title = "Raporty w budowie"
            render "coming_soon"
        end
    end
  end
  