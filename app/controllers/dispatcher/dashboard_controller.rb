module Dispatcher
    class DashboardController < ApplicationController
      def index; end
        
        def calendar
            @page_title = "Kalendarz w budowie"
            render "coming_soon" 
        end

        def notifications
            @page_title = "Powiadomienia i raporty w budowie"
            render "coming_soon"
        end
    end
  end
  