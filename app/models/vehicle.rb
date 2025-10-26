class Vehicle < ApplicationRecord
  belongs_to :vehicle_type
  has_many :availabilities, as: :availableable, dependent: :destroy
  has_many :order_vehicles, dependent: :restrict_with_error
  has_many :orders, through: :order_vehicles

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
    overlapping_orders = orders.joins(:order_vehicles)
                               .where(order_vehicles: { current: true })
                               .where.not(id: exclude_order_id)
                               .where("(pickup_date BETWEEN ? AND ?) OR (delivery_date BETWEEN ? AND ?)",
                                      start_date, end_date, start_date, end_date)
    overlapping_orders.exists?
  end

end
