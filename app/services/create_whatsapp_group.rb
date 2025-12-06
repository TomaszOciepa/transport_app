# app/services/create_whatsapp_group.rb
require "net/http"
require "uri"
require "json"

class CreateWhatsappGroup
  BOT_URL = "http://localhost:3005/create_group" # ← poprawiony endpoint

  def self.call(group_name:, driver_phone:, message: nil)
    uri = URI.parse(BOT_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"

    request.body = {
      group_name: group_name,
      driver_phone: driver_phone.gsub("+", "") # WhatsApp format
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    JSON.parse(response.body) rescue nil
  rescue => e
    Rails.logger.error("CreateWhatsappGroup error: #{e.message}")
    nil
  end
end
