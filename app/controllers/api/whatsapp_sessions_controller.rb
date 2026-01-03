class Api::WhatsappSessionsController < ApplicationController
      skip_before_action :verify_authenticity_token
  
      # POST /api/whatsapp_session/qr
      def qr
        session = WhatsappSession.find_or_create_by!(user_id: params[:user_id])
  
        session.update!(
          qr_code: params[:qr],
          status: "pending"
        )
  
        Rails.logger.info "WhatsApp QR saved for user #{params[:user_id]}"
  
        head :ok
      end

      def status
        session = WhatsappSession.find_by!(user_id: params[:user_id])
        user    = session.user
      
        incoming_status = params[:status]
        incoming_phone  = params[:phone]
      
        # ============================
        # STATUS READY → VALIDATION
        # ============================
        if incoming_status == "ready"
      
          if normalize_phone(incoming_phone) != normalize_phone(user.phone)
            Rails.logger.warn(
              "WhatsApp phone mismatch for user #{user.id}: " \
              "expected #{user.phone}, got #{incoming_phone}"
            )
      
            # disconnect Node (cleanup only)
            Faraday.post(
              "http://localhost:3005/sessions/disconnect",
              { user_id: user.id }.to_json,
              "Content-Type" => "application/json"
            )
      
            # IMPORTANT: special state for UI
            session.update!(status: "invalid_phone")
      
            return head :ok
          end
      
          # NUMBERS MATCH → READY
          session.update!(
            status: "ready",
            phone: incoming_phone
          )
      
          return head :ok
        end
      
        # ============================
        # OTHER STATUSES
        # ============================
        session.update!(status: incoming_status)
      
        head :ok
      end
      
      
      
      def connect
        session = WhatsappSession.find_or_create_by!(
          user_id: params[:user_id]
        )
      
        if session.status == "ready"
          return render json: { status: "already_connected" }
        end
      
        # pokazujemy spinner
        session.update!(status: "pending")
      
        begin
          Faraday.post(
            "http://localhost:3005/sessions",
            { user_id: session.user_id }.to_json,
            "Content-Type" => "application/json"
          )
        rescue Faraday::ConnectionFailed, Errno::ECONNREFUSED => e
          Rails.logger.error "WhatsApp Node unavailable: #{e.message}"
      
          # WE REVERSE THE STATUS - the spinner disappears
          session.update!(status: "disconnected")
      
          return render json: {
            error: "whatsapp_node_unavailable"
          }, status: :service_unavailable
        end
      
        render json: { status: "starting" }
      end
      
      

      def disconnect
        session = WhatsappSession.find_by!(user_id: params[:user_id])
      
        Rails.logger.info "Disconnect requested for user #{params[:user_id]}"
      
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

      private

      def normalize_phone(phone)
        phone.to_s.gsub(/\D/, "")
      end
      
end
