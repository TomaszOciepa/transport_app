module Dispatcher
    class MessagesController < ApplicationController

        before_action :set_groups

        def index
            @page_title = "Wiadomości"
            
            # Selecting the active group from the parameter or the first one from the list
            if params[:group_id].present?
              @active_group = @groups.find { |g| g.id == params[:group_id].to_i }
            end
      
            @active_group ||= @groups.first
      
           # Download messages for the active group
            @messages = @active_group ? @active_group.whatsapp_messages.order(:timestamp) : []
          end

          def send_whatsapp
            message_body = params[:body]
            whatsapp_group = WhatsappGroup.find_by(id: params[:whatsapp_group_id])
          
            if whatsapp_group && message_body.present?
              # dispatch to Node.js
              uri = URI.parse("http://localhost:3005/send_to_group")
              http = Net::HTTP.new(uri.host, uri.port)
              req = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
              req.body = { group_id: whatsapp_group.whatsapp_group_id, message: message_body }.to_json
              http.request(req)
          
             # write to Rails DB
              WhatsappMessage.create!(
                whatsapp_group: whatsapp_group,
                from_number: "BOT",
                to_number: whatsapp_group.whatsapp_group_id,
                body: message_body,
                is_from_driver: false,
                timestamp: Time.current,
                raw_data: {}
              )
          
              redirect_to dispatcher_messages_path(group_id: whatsapp_group.id), notice: "Wiadomość wysłana."
            else
              redirect_to dispatcher_messages_path(group_id: whatsapp_group&.id), alert: "Nie można wysłać wiadomości."
            end
          end
          
      
      private

       
        def set_groups
        @groups = WhatsappGroup.includes(:driver).order(created_at: :desc)
        end

    end
  end
  