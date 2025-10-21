class OrderVehicle < ApplicationRecord
  belongs_to :order
  belongs_to :vehicle
  belongs_to :user

  validates :vehicle_id, :order_id, :user_id, presence: true

  before_create :unset_previous_current

  private

  def unset_previous_current
    if current
      order.order_vehicles.where(current: true).update_all(current: false)
    end
  end

end
