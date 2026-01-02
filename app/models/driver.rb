class Driver < ApplicationRecord
    belongs_to :license_category, optional: true
    has_many :availabilities, as: :availableable, dependent: :destroy
    has_many :vehicle_drivers, dependent: :restrict_with_error
    has_many :vehicles, through: :vehicle_drivers


    validates :first_name, :last_name, :email, :license_category, presence: true
    validates :email, uniqueness: true

    
    def current_vehicles
      Vehicle.joins(:vehicle_drivers)
             .where(vehicle_drivers: { driver_id: id, current: true })
             .distinct
    end

    def current_status
      now = Time.current
      if availabilities.any? { |a| a.start_time <= now && a.end_time >= now }
        "available"
      else
        "unavailable"
      end
    end
    
    
    def current_status_i18n
      I18n.t("activerecord.attributes.driver.statuses.#{current_status}")
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def can_drive?(vehicle_type)
      case vehicle_type.name
      when "Samochód osobowy"
        ["B", "C", "C+E"].include?(license_category.name)
      when "Bus"
        ["B", "C", "C+E"].include?(license_category.name)
      when "Ciężarówka solo"
        ["C", "C+E"].include?(license_category.name)
      when "Ciężarówka z naczepą"
        license_category.name == "C+E"
      else
        false
      end
    end

    def available_for?(order)
      return false unless available_during?(order.pickup_date, order.delivery_date)
      true
    end

    def available?(time = Time.current)
      availabilities.where("start_time <= ? AND end_time >= ?", time, time).exists?
    end

    private

    def available_during?(start_date, end_date)
      availabilities.any? do |a|
        a.start_time <= start_date && a.end_time >= end_date
      end
    end
  
end
