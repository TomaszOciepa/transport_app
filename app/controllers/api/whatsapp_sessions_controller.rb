class Api::WhatsappSessionsController < ApplicationController
      # Node nie ma cookies ani sesji Devise
      skip_before_action :verify_authenticity_token
  
      # POST /api/whatsapp_session/qr
      def qr
        # user_id przychodzi z Node
        session = WhatsappSession.find_or_create_by!(user_id: params[:user_id])
  
        session.update!(
          qr_code: params[:qr],
          status: "pending"
        )
  
        Rails.logger.info "✅ WhatsApp QR saved for user #{params[:user_id]}"
  
        head :ok
      end

      def status
        session = WhatsappSession.find_by!(user_id: params[:user_id])
  
        session.update!(
          status: params[:status],
          phone: params[:phone]
        )
  
        Rails.logger.info(
          "✅ WhatsApp status updated for user #{params[:user_id]}: #{params[:status]}"
        )
  
        head :ok
      end

      def create
        session = current_user.whatsapp_session
      
        if session&.status == "ready"
          return render json: { status: "already_connected" }
        end
      
        session ||= current_user.create_whatsapp_session!
        session.update!(status: "pending")
      
        Faraday.post(
          "http://localhost:3005/sessions",
          { user_id: current_user.id }.to_json,
          "Content-Type" => "application/json"
        )
      
        redirect_to messages_path
      end

      def disconnect
        session = WhatsappSession.find_by!(user_id: params[:user_id])
      
        Rails.logger.info "🔴 Disconnect requested for user #{params[:user_id]}"
      
        # Call Node to properly close WhatsApp Web session
        Faraday.post(
          "http://localhost:3005/sessions/disconnect",
          { user_id: params[:user_id] }.to_json,
          "Content-Type" => "application/json"
        )
      
        # We DO NOT update DB status here
        # Node will notify us back via /api/whatsapp_session/status
      
        head :ok
      end
      
end
