require "net/http"
require "json"

class OpenRouteService
  BASE_URL = "https://api.openrouteservice.org/v2/directions/driving-car".freeze

  def self.distance_km(start_lon:, start_lat:, end_lon:, end_lat:)
    api_key = ENV["ORS_API_KEY"]
    return 0 unless api_key.present?

    url = URI("#{BASE_URL}?api_key=#{api_key}&start=#{start_lon},#{start_lat}&end=#{end_lon},#{end_lat}")

    begin
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
      distance_m = data.dig("features", 0, "properties", "summary", "distance")
      distance_m ? (distance_m / 1000.0).round(2) : 0
    rescue => e
      Rails.logger.error("OpenRouteService error: #{e.message}")
      0
    end
  end
end
