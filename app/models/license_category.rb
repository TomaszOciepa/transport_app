class LicenseCategory < ApplicationRecord
    has_many :drivers

    validates :name, presence: true, uniqueness: true
    validates :max_hours_per_day, numericality: { greater_than: 0 }
    validates :max_hours_per_week, numericality: { greater_than: 0 }
end
