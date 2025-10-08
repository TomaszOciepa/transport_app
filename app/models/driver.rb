class Driver < ApplicationRecord
    has_many :orders

    enum :status, [ :available, :busy, :off_duty ]

    validates :first_name, :last_name, :email, :license_category, presence: true
    validates :email, uniqueness: true


    def status_name
        I18n.t("activerecord.attributes.driver.statuses.#{status}")
    end

end
