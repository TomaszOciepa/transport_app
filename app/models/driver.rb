class Driver < ApplicationRecord
    belongs_to :license_category, optional: true
    has_many :orders
    has_many :availabilities, as: :availableable, dependent: :destroy

    validates :first_name, :last_name, :email, :license_category, presence: true
    validates :email, uniqueness: true

    def current_status
      now = Time.current
      if availabilities.any? { |a| a.start_time <= now && a.end_time >= now }
        "available"
      else
        "off_duty"
      end
    end
    
    
    def current_status_i18n
      I18n.t("activerecord.attributes.driver.statuses.#{current_status}")
    end

end
