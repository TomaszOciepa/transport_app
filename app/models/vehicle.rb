class Vehicle < ApplicationRecord
  belongs_to :vehicle_type
  has_many :orders
  has_many :availabilities, as: :availableable, dependent: :destroy

   validates :brand, :registration_number, :vehicle_type_id, presence: true
   validates :registration_number, uniqueness: true

   def current_status
    now = Time.current
    
    if availabilities.any? { |a| a.start_time <= now && a.end_time >= now }
      "available"
    else
      "unavailable"
    end
  end

   def current_status_i18n
    I18n.t("activerecord.attributes.vehicle.statuses.#{status}")
  end

end
