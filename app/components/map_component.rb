class MapComponent < ViewComponent::Base
    def initialize(pickup_lat:, pickup_lon:, delivery_lat:, delivery_lon:)
      @pickup_lat = pickup_lat.presence || 52.2297
      @pickup_lon = pickup_lon.presence || 21.0122
      @delivery_lat = delivery_lat.presence || 54.352067
      @delivery_lon = delivery_lon.presence || 18.648424
      @ors_api_key = ENV["ORS_API_KEY"]
    end
  end
  