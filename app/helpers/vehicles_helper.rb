module VehiclesHelper
  def vehicle_logo_for(vehicle)
    brand = vehicle.brand.to_s.downcase

    case
    when brand.include?("daf")
      "daf-logo.png"
    when brand.include?("scania")
      "scania_logo.png"
    when brand.include?("volvo")
      "volvo-logo.jpg"
    when brand.include?("mercedes")
      "mercedes-logo.png"
    else
      "noname-logo.jpg"
    end
  end
end
