class Vehicle < ApplicationRecord
  belongs_to :vehicle_type
  has_many :availabilities, as: :availableable, dependent: :destroy
  has_many :order_vehicles, dependent: :restrict_with_error
  has_many :orders, through: :order_vehicles
  has_many :vehicle_drivers, dependent: :destroy
  has_many :drivers, through: :vehicle_drivers

   validates :brand, :registration_number, :vehicle_type_id, presence: true
   validates :registration_number, uniqueness: true

    def current_driver
      vehicle_drivers.includes(:driver).find_by(current: true)&.driver
    end

    def current_orders
      Order.joins(:order_vehicles)
          .where(order_vehicles: { vehicle_id: id, current: true })
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
      I18n.t("activerecord.attributes.vehicle.statuses.#{current_status}")
    end


    def available_for?(order)
      return false unless available_during?(order.pickup_date, order.delivery_date)
      return false if assigned_during?(order.pickup_date, order.delivery_date, exclude_order_id: order.id)
      true
    end

    def distance_to_order(order)
      @distance_cache ||= {}
      return @distance_cache[order.id] if @distance_cache.key?(order.id)

      last_order = orders.joins(:order_vehicles)
                  .where(order_vehicles: { current: true })
                  .where.not(delivery_lat: nil, delivery_lon: nil, delivery_date: nil)
                  .where("delivery_date < ?", order.pickup_date)
                  .order(delivery_date: :desc)
                  .first

      start_lat, start_lon = if last_order
                              [last_order.delivery_lat, last_order.delivery_lon]
                            else
                              [54.399063, 18.6675238] # default starting point Gdańsk
                            end

      return 0 unless order.pickup_lat.present? && order.pickup_lon.present?

      distance_km = OpenRouteService.distance_km(
        start_lon: start_lon,
        start_lat: start_lat,
        end_lon:   order.pickup_lon,
        end_lat:   order.pickup_lat
      )

      @distance_cache[order.id] = distance_km.round(2)
    end

    def eta_to_order(order)
      distance_km = distance_to_order(order)
      return nil if distance_km.zero? || vehicle_type.max_speed.nil?

      travel_hours = distance_km / vehicle_type.max_speed

      last_order = orders
                    .where.not(delivery_date: nil)
                    .where("delivery_date < ?", order.pickup_date)
                    .order(delivery_date: :desc)
                    .first

      start_time = last_order&.delivery_date || Time.current

      start_time + travel_hours.hours
    end



  private

  def available_during?(start_date, end_date)
    availabilities.any? do |a|
      a.start_time <= start_date && a.end_time >= end_date
    end
  end

  def assigned_during?(start_date, end_date, exclude_order_id: nil)
    overlapping_orders = orders.joins(:order_vehicles)
          .where(order_vehicles: { current: true })
          .where.not(id: exclude_order_id)
          .where("(pickup_date BETWEEN ? AND ?) OR (delivery_date BETWEEN ? AND ?)",
            start_date, end_date, start_date, end_date)
    overlapping_orders.exists?
  end

end
