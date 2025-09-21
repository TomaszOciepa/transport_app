class Order < ApplicationRecord
  belongs_to :vehicle_type
  belongs_to :service_type

  geocoded_by :pickup_address, latitude: :pickup_lat, longitude: :pickup_lon
  geocoded_by :delivery_address, latitude: :delivery_lat, longitude: :delivery_lon

  before_validation :geocode_addresses
  before_save :calculate_price_and_delivery

  def geocode_addresses
    if pickup_address.present? && pickup_lat.blank? && pickup_lon.blank?
      geo = Geocoder.search(pickup_address).first
      if geo
        self.pickup_lat = geo.latitude
        self.pickup_lon = geo.longitude
      end
    end

    if delivery_address.present? && delivery_lat.blank? && delivery_lon.blank?
      geo = Geocoder.search(delivery_address).first
      if geo
        self.delivery_lat = geo.latitude
        self.delivery_lon = geo.longitude
      end
    end
  end

  def calculate_price_and_delivery
    
    if pickup_lat.present? && pickup_lon.present? && delivery_lat.present? && delivery_lon.present?
      self.distance_km = Geocoder::Calculations.distance_between(
        [pickup_lat, pickup_lon],
        [delivery_lat, delivery_lon]
      )
    else
      self.distance_km ||= 0
    end

    self.price = vehicle_type.price_per_km * distance_km * service_type.multiplier

    base_speed = vehicle_type.max_speed 
    travel_hours = distance_km / base_speed
    travel_hours *= service_type.multiplier

    start_time = pickup_date&.to_time.change(hour: 9) || Time.current
    self.delivery_date ||= start_time + travel_hours.hours
  end
end

