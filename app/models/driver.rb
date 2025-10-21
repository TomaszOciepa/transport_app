class Driver < ApplicationRecord
    belongs_to :license_category, optional: true
    has_many :availabilities, as: :availableable, dependent: :destroy
    has_many :order_drivers, dependent: :restrict_with_error
    has_many :orders, through: :order_drivers

    validates :first_name, :last_name, :email, :license_category, presence: true
    validates :email, uniqueness: true

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

end
