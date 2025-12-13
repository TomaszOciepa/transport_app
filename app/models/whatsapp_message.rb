class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_group

  has_one_attached :media

  enum :message_type, {
    text: "text",
    image: "image",
    video: "video",
    audio: "audio",
    document: "file"
  }


  # =========================
  # 📌 SCOPES
  # =========================

  scope :unread, -> { where(read_at: nil) }
  scope :read,   -> { where.not(read_at: nil) }

  # =========================
  # 🔍 HELPERS
  # =========================

  def unread?
    read_at.nil?
  end

  def mark_as_read!
    return if read_at.present?

    update!(read_at: Time.current)
  end
end
