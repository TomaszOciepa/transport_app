class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_group

  has_one_attached :media

  validate :media_size_within_limit

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

  private

  def media_size_within_limit
    return unless media.attached?

    if media.blob.byte_size > 16.megabytes
      errors.add(:media, "maksymalny rozmiar pliku to 16 MB")
    end
  end
  
end
