# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :vehicle_type
  belongs_to :service_type

  # Geocoding adresów
  geocoded_by :pickup_address, latitude: :pickup_lat, longitude: :pickup_lon
  geocoded_by :delivery_address, latitude: :delivery_lat, longitude: :delivery_lon

  before_validation :geocode_addresses
  before_save :calculate_price_and_delivery

  # Geokodowanie adresów na współrzędne
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

  # Obliczenie dystansu, ceny i przewidywanej daty dostawy
  def calculate_price_and_delivery
    if pickup_lat.present? && pickup_lon.present? && delivery_lat.present? && delivery_lon.present?
      self.distance_km = fetch_distance_from_ors
    else
      self.distance_km ||= 0
    end

    # Cena
    self.price = vehicle_type.price_per_km * distance_km * service_type.multiplier

    # Przewidywany czas dostawy
    base_speed = vehicle_type.max_speed
    travel_hours = distance_km / base_speed
    travel_hours *= service_type.multiplier

    start_time = pickup_date&.to_time.change(hour: 9) || Time.current
    self.delivery_date ||= start_time + travel_hours.hours
  end

  private

  # Wywołanie ORS, zwraca dystans w kilometrach
  def fetch_distance_from_ors
    api_key = ENV['ORS_API_KEY']
    return 0 unless api_key.present?

    url = URI("https://api.openrouteservice.org/v2/directions/driving-car?api_key=#{api_key}&start=#{pickup_lon},#{pickup_lat}&end=#{delivery_lon},#{delivery_lat}")

    begin
      res = Net::HTTP.get(url)
      data = JSON.parse(res)

      if data['features'] && data['features'][0] && data['features'][0]['properties'] && data['features'][0]['properties']['summary']
        distance_m = data['features'][0]['properties']['summary']['distance']
        return distance_m / 1000.0
      end
    rescue => e
      Rails.logger.error("Błąd ORS: #{e.message}")
    end

    0
  end
end
