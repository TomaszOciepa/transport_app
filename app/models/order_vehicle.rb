class OrderVehicle < ApplicationRecord
  belongs_to :order
  belongs_to :vehicle
  belongs_to :user

  has_one :whatsapp_group, dependent: :destroy 


  validates :vehicle_id, :order_id, :user_id, presence: true
  validate :vehicle_must_be_available
  
  before_create :unset_previous_current

  private

  def unset_previous_current
    if current
      order.order_vehicles.where(current: true).update_all(current: false)
    end
  end

  def vehicle_must_be_available
    unless vehicle.available_for?(order)
      errors.add(:vehicle, "nie jest dostępny w okresie tego zamówienia")
    end
  end

end
