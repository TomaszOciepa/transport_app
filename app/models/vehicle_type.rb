class VehicleType < ApplicationRecord
    has_many :orders, dependent: :restrict_with_exception
end
