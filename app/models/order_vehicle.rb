class OrderVehicle < ApplicationRecord
  belongs_to :order
  belongs_to :vehicle
  belongs_to :user

  validates :vehicle_id, :order_id, :user_id, presence: true
  validate :vehicle_must_be_available

  before_create :unset_previous_current

  # after_commit :ensure_whatsapp_groups_for_vehicle, on: [ :create, :update ]


  private

  # def ensure_whatsapp_groups_for_vehicle
  #   return unless current?
  #   return unless vehicle.present?

  #   driver = vehicle.current_driver
  #   return unless driver.present?

  #   Whatsapp::EnsureGroupsForVehicle.call(vehicle)
  # end

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
