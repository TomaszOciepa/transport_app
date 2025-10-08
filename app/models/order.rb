# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle_type
  belongs_to :service_type
  belongs_to :driver, optional: true
  belongs_to :vehicle, optional: true

  attr_accessor :pickup_city, :pickup_postcode, :delivery_city, :delivery_postcode

  enum :status, [ :pending, :scheduled, :in_transit, :completed, :canceled ]


  before_validation :combine_full_addresses
  before_validation :geocode_addresses
  before_save :calculate_price_and_delivery
  before_create :generate_order_number

  validates :order_number, uniqueness: true
  validates :pickup_address, :delivery_address, :vehicle_type_id, :service_type_id, :pickup_date, presence: true

  validates :pickup_lat, :pickup_lon, :delivery_lat, :delivery_lon, presence: true
  validates :pickup_lat, :pickup_lon, :delivery_lat, :delivery_lon, numericality: true

  def status_name
    I18n.t("activerecord.attributes.order.statuses.#{status}")
  end

  # Geocoding addresses to coordinates
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
      self.distance_km = fetch_distance_from_ors
    else
      self.distance_km ||= 0
    end

  
    self.price = vehicle_type.price_per_km * distance_km * service_type.multiplier


    base_speed = vehicle_type.max_speed
    travel_hours = distance_km / base_speed
    self.travel_time = travel_hours
    # travel_hours *= service_type.multiplier

    # start_time = pickup_date&.to_time.change(hour: 9) || Time.current
    start_time = start_time = pickup_date || Time.zone.now

    self.delivery_date ||= start_time + travel_hours.hours
  end

  def combine_full_addresses
    if pickup_address.present?
      self.pickup_address = [pickup_address, pickup_postcode, pickup_city].compact.join(', ')
    end
  
    if delivery_address.present?
      self.delivery_address = [delivery_address, delivery_postcode, delivery_city].compact.join(', ')
    end
  end
  
  private

  def generate_order_number
    date_prefix = Time.current.strftime("%Y-%m-%d") # rrrr-mm-dd

    # Count how many orders there are already on this day
    count_today = Order.where("created_at >= ? AND created_at < ?", Time.current.beginning_of_day, Time.current.end_of_day).count

    sequence_number = (count_today + 1).to_s.rjust(5, '0') # 00001, 00002, ...
    self.order_number = "#{date_prefix}-#{sequence_number}"

    # collision protection (uniqueness)
    while Order.exists?(order_number: self.order_number)
      count_today += 1
      sequence_number = (count_today + 1).to_s.rjust(5, '0')
      self.order_number = "#{date_prefix}-#{sequence_number}"
    end
  end

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
