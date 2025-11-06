class Order < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle_type
  belongs_to :service_type

  has_many :order_vehicles, dependent: :destroy
  has_many :vehicle_history, through: :order_vehicles, source: :vehicle

  attr_accessor :pickup_city, :pickup_postcode, :delivery_city, :delivery_postcode

  enum :status, [ :pending, :planned, :in_progress, :completed, :canceled ]


  before_validation :combine_full_addresses
  before_validation :geocode_addresses
  before_save :calculate_price_and_delivery
  before_create :generate_order_number

  validates :order_number, uniqueness: true
  validates :pickup_address, :delivery_address, :vehicle_type_id, :service_type_id, :pickup_date, presence: true

  validates :pickup_lat, :pickup_lon, :delivery_lat, :delivery_lon, presence: true
  validates :pickup_lat, :pickup_lon, :delivery_lat, :delivery_lon, numericality: true

  def status_name
    I18n.t("activerecord.attributes.order.statuses.#{current_status}")
  end

  def current_status
    return :canceled if canceled?
    return :completed if delivery_date.present? && Time.current >= delivery_date
    return :in_progress if pickup_date.present? && Time.current >= pickup_date
    return :planned if current_vehicle.present? && current_vehicle.vehicle_drivers.exists?(current: true)
    :pending
  end

  def current_order_vehicle
    order_vehicles.find_by(current: true)
  end

  def current_vehicle
    current_order_vehicle&.vehicle
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
      self.distance_km = OpenRouteService.distance_km(
        start_lon: pickup_lon,
        start_lat: pickup_lat,
        end_lon: delivery_lon,
        end_lat: delivery_lat
      )
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

  def pickup_place
    pickup_address&.split(',')&.last&.strip
  end

  def delivery_place
    delivery_address&.split(',')&.last&.strip
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



 
end
