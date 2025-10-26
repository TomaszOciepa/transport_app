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

    def available_for?(order)
      return false unless available_during?(order.pickup_date, order.delivery_date)
      return false if assigned_during?(order.pickup_date, order.delivery_date, exclude_order_id: order.id)
      true
    end

    private

    def available_during?(start_date, end_date)
      availabilities.any? do |a|
        a.start_time <= start_date && a.end_time >= end_date
      end
    end
  
    def assigned_during?(start_date, end_date, exclude_order_id: nil)
      overlapping_orders = orders.joins(:order_drivers)
                                 .where(order_drivers: { current: true })
                                 .where.not(id: exclude_order_id)
                                 .where("(pickup_date BETWEEN ? AND ?) OR (delivery_date BETWEEN ? AND ?)",
                                        start_date, end_date, start_date, end_date)
      overlapping_orders.exists?
    end

end
