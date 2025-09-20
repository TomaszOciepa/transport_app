class Order < ApplicationRecord
  belongs_to :vehicle_type
  belongs_to :service_type

  # enum status: { pending: 0, confirmed: 1, delivered: 2 }
end
