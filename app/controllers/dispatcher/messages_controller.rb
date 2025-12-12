module Dispatcher
  class MessagesController < ApplicationController
    before_action :set_groups
    before_action :set_active_group, only: :index


    def index
      @page_title = "Wiadomości"
    
      session[:active_whatsapp_group_id] = @active_group&.id
    
      @messages =
        if @active_group
          @active_group.whatsapp_messages.order(:timestamp)
        else
          []
        end
    end

    def mark_as_read
      Rails.logger.warn("🔥 MARK_AS_READ CALLED id=#{params[:id]}")
    
      whatsapp_group = WhatsappGroup.find(params[:id])
    
      Rails.logger.warn("🔥 GROUP FOUND id=#{whatsapp_group.id}")
    
      updated =
        WhatsappMessage
          .where(whatsapp_group_id: whatsapp_group.id, read_at: nil)
          .update_all(read_at: Time.current)
    
      Rails.logger.warn("🔥 UPDATED COUNT = #{updated}")
    
      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_notifications",
        target: "chat_group_#{whatsapp_group.id}",
        partial: "dispatcher/messages/chat_row",
        locals: {
          group: whatsapp_group.reload,
          active: true
        }
      )
    
      head :ok
    end
    
    
    

    def send_whatsapp
      message_body   = params[:body]
      whatsapp_group = WhatsappGroup.find_by(id: params[:whatsapp_group_id])

      unless whatsapp_group && message_body.present?
        return respond_to do |format|
          format.turbo_stream { head :unprocessable_entity }
          format.html {
            redirect_to dispatcher_messages_path(group_id: whatsapp_group&.id),
            alert: "Nie można wysłać wiadomości."
          }
        end
      end

      # --- Wyślij do Node.js ---
      uri  = URI.parse("http://localhost:3005/send_to_group")
      http = Net::HTTP.new(uri.host, uri.port)
      req  = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      req.body = {
        group_id: whatsapp_group.whatsapp_group_id,
        message:  message_body
      }.to_json

      http.request(req)

      # --- Zapis do DB ---
      @message = WhatsappMessage.create!(
        whatsapp_group: whatsapp_group,
        from_number:    "BOT",
        to_number:      whatsapp_group.whatsapp_group_id,
        body:           message_body,
        is_from_driver: false,
        timestamp:      Time.current,
        raw_data:       {},
        read_at:        Time.current
      )

      Rails.logger.info("SEND_WHATSAPP: group=#{whatsapp_group.id} msg_id=#{@message.id}")
      Rails.logger.info("BROADCAST_CHAT: stream=chat_channel_#{whatsapp_group.id} target=messages msg_id=#{@message.id}")


      # 🔥 REALTIME PRAWEJ KOLUMNY
      Turbo::StreamsChannel.broadcast_append_to(
        "chat_channel_#{whatsapp_group.id}",
        target: "messages",
        partial: "dispatcher/messages/message",
        locals: { msg: @message } # ← TERAZ OK ✅
      )

      respond_to do |format|
        # ⬇⬇⬇ TO JEST KLUCZ ⬇⬇⬇
        format.turbo_stream { head :no_content }
    
        format.html {
          redirect_to dispatcher_messages_path(group_id: whatsapp_group.id),
          notice: "Wiadomość wysłana."
        }
      end
    end

    def send_order_to_group
      whatsapp_group = WhatsappGroup.find(params[:id])
      order          = whatsapp_group.order

      unless whatsapp_group && order
        return redirect_to dispatcher_messages_path,
          alert: "Nie można wysłać zlecenia."
      end

      message_body = <<~MSG
        Załadunek: #{order.pickup_address}, data: #{l(order.pickup_date, format: :short)}
        Rozładunek: #{order.delivery_address}, data: #{l(order.delivery_date, format: :short)}
      MSG

      # --- send to Node.js / WhatsApp ---
      uri  = URI.parse("http://localhost:3005/send_to_group")
      http = Net::HTTP.new(uri.host, uri.port)
      req  = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      req.body = {
        group_id: whatsapp_group.whatsapp_group_id,
        message:  message_body
      }.to_json

      http.request(req)

      # --- save to DB ---
      WhatsappMessage.create!(
        whatsapp_group: whatsapp_group,
        from_number:    "BOT",
        to_number:      whatsapp_group.whatsapp_group_id,
        body:           message_body,
        is_from_driver: false,
        timestamp:      Time.current,
        raw_data:       {},
        read_at:        Time.current # ⬅ systemowe = przeczytane
      )

      whatsapp_group.update!(order_sent: true)

      redirect_to dispatcher_messages_path(
        group_id: whatsapp_group.id
      ), notice: "Zlecenie wysłane."
    end

    private

    def set_groups
      @groups = WhatsappGroup.includes(:driver).order(created_at: :desc)
    end

    def set_active_group
      @active_group =
        if params[:group_id].present?
          @groups.find { |g| g.id == params[:group_id].to_i }
        else
          @groups.first
        end
    end

  end
end
