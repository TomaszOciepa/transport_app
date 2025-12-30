    class MenuBroadcaster
      STREAM = "dispatcher_menu".freeze
      DEFAULT_TITLE = "Panel Dyspozytora - TransportApp".freeze
      UNREAD_TITLE  = "🔔 Nowa wiadomość • TransportApp".freeze
  
      def self.broadcast!
        has_unread = WhatsappMessage.where(read_at: nil).exists?
  
       # Badge: replace the content of <span id="menu-messages-badge">
        Turbo::StreamsChannel.broadcast_update_to(
          STREAM,
          target: "menu-messages-badge",
          partial: "dispatcher/shared/menu_messages_badge",
          locals: { has_unread: has_unread }
        )
  
        # Title: replace the entire <title id="page-title">
        Turbo::StreamsChannel.broadcast_replace_to(
          STREAM,
          target: "page-title",
          partial: "dispatcher/shared/page_title",
          locals: { title: (has_unread ? UNREAD_TITLE : DEFAULT_TITLE) }
        )
      end
    end

  