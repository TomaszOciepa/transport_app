class WhatsappSender
  SEND_URL = "http://localhost:3005/send"
  SEND_GROUP_URL = "http://localhost:3005/send_to_group"

  # wysyłanie do pojedynczego numeru
  def self.send_message(phone, message)
    uri = URI.parse(SEND_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { phone: phone.gsub("+", ""), message: message }.to_json

    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
  rescue => e
    Rails.logger.error("WhatsappSender error: #{e.message}")
  end

  # wysyłanie do grupy
  def self.send_message_to_group(group_id, message)
    uri = URI.parse(SEND_GROUP_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { group_id: group_id, message: message }.to_json

    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
  rescue => e
    Rails.logger.error("WhatsappSender (group) error: #{e.message}")
  end
end
