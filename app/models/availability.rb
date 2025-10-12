class Availability < ApplicationRecord
    belongs_to :availableable, polymorphic: true

  end