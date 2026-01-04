class LicenseCategory < ApplicationRecord
    has_many :drivers
    has_and_belongs_to_many :vehicle_types

    validates :name, presence: true, uniqueness: true
    validates :max_hours_per_day, numericality: { greater_than: 0 }
    validates :max_hours_per_week, numericality: { greater_than: 0 }


    def included_categories
        case name
        when "C+E"
          [ "C", "B" ]
        when "C"
          [ "B" ]
        else
          []
        end
    end
end
