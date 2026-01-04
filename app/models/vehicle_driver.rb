class VehicleDriver < ApplicationRecord
    belongs_to :vehicle
    belongs_to :driver
    belongs_to :user

    validates :driver_id, :vehicle_id, :user_id, presence: true

    before_create :unset_previous_current

    private

    def unset_previous_current
      if current
        vehicle.vehicle_drivers.where(current: true).update_all(current: false)
      end
    end
end
