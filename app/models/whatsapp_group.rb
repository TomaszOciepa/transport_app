class WhatsappGroup < ApplicationRecord
  belongs_to :order
  belongs_to :driver

  has_many :whatsapp_messages, dependent: :destroy

  # =========================
  # 🔔 UNREAD / READ LOGIC
  # =========================

  # Liczba nieprzeczytanych wiadomości
  def unread_count
    whatsapp_messages.where(read_at: nil).count
  end

  # Czy są jakiekolwiek nieprzeczytane?
  def unread?
    whatsapp_messages.where(read_at: nil).exists?
  end

  # Oznacz wszystkie jako przeczytane
  def mark_all_as_read!
    whatsapp_messages
      .where(read_at: nil)
      .update_all(read_at: Time.current)
  end

  # =========================
  # 💬 MESSAGE HELPERS
  # =========================

  # Ostatnia wiadomość (do podglądu w liście)
  def last_message
    whatsapp_messages.order(timestamp: :desc).first
  end

  # Treść ostatniej wiadomości (bezpieczna)
  def last_message_body
    last_message&.body.to_s
  end

  # Timestamp ostatniej aktywności (do sortowania)
  def last_activity_at
    last_message&.timestamp || created_at
  end
end
