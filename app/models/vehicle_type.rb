class VehicleType < ApplicationRecord
    has_many :vehicles, dependent: :restrict_with_exception
    has_many :orders, dependent: :restrict_with_exception

    has_and_belongs_to_many :license_categories

    validates :capacity_weight, :capacity_volume, numericality: { greater_than_or_equal_to: 0 }


    def can_driver_operate?(driver)
        driver_categories = [driver.license_category.name] + driver.license_category.included_categories
        license_categories.any? { |lc| driver_categories.include?(lc.name) }
      end
      
end
