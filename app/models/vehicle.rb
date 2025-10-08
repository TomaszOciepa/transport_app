class Vehicle < ApplicationRecord
  belongs_to :vehicle_type
  has_many :orders

   enum :status, [ :available, :in_transit, :maintenance]

   validates :brand, :registration_number, :vehicle_type_id, :required_license, presence: true
   validates :registration_number, uniqueness: true
end
