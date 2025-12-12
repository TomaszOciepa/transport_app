class WhatsappMessage < ApplicationRecord
  belongs_to :whatsapp_group

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
