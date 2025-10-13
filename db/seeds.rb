# VehicleType.create!([
#   { name: "Samochód osobowy", capacity: 500, max_speed: 110, price_per_km: 1.20 },
#   { name: "Bus", capacity: 2000, max_speed: 95, price_per_km: 2.50 },
#   { name: "Tir", capacity: 20000, max_speed: 80, price_per_km: 4.00 },
#   { name: "Van", capacity: 800, max_speed: 100, price_per_km: 2.00 }
# ])

  
#   ServiceType.create!([
#     { name: "Standard", multiplier: 1.0 },
#     { name: "Express", multiplier: 1.5 }
#   ])



#   User.create!([
#     {email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: :client},
#     { email: 'dispatcher@example.com', password: 'password123', password_confirmation: 'password123', role: :dispatcher},
#     {email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: :admin}
#   ])

# b_category = LicenseCategory.find_by(name: "B")
# c_category = LicenseCategory.find_by(name: "C")
# ce_category = LicenseCategory.find_by(name: "C+E")

# Driver.create!([
#   {
#     first_name: "Jan",
#     last_name: "Kowalski",
#     email: "jan.kowalski@example.com",
#     phone: "600123456",
#     license_category: b_category,
#     birth_year: 1985,
#     available_from: "08:00",
#     available_to: "18:00",
#     status: :available
#   },
#   {
#     first_name: "Anna",
#     last_name: "Nowak",
#     email: "anna.nowak@example.com",
#     phone: "601987654",
#     license_category: c_category,
#     birth_year: 1990,
#     available_from: "07:00",
#     available_to: "16:00",
#     status: :available
#   },
#   {
#     first_name: "Piotr",
#     last_name: "Wiśniewski",
#     email: "piotr.wisniewski@example.com",
#     phone: "602555777",
#     license_category: b_category, # jeśli chcesz przypisać kilka kategorii, trzeba zmienić relację na HABTM
#     birth_year: 1982,
#     available_from: "09:00",
#     available_to: "17:00",
#     status: :off_duty
#   }
# ])
  

# Vehicle.create!([
#     {
#       brand: "Dacia",
#       registration_number: "GD12345",
#       vehicle_type: VehicleType.find_by(name: "Samochód osobowy")
#     },
#     {
#       brand: "Mercedes Sprinter",
#       registration_number: "GD54321",
#       vehicle_type: VehicleType.find_by(name: "Bus")
#     },
#     {
#       brand: "Scania R450",
#       registration_number: "GD11223",
#       vehicle_type: VehicleType.find_by(name: "Ciężarówka solo")
#     },
#     {
#       brand: "Scania S770",
#       registration_number: "GD44556",
#       vehicle_type: VehicleType.find_by(name: "Ciężarówka z naczepą")
#     }
#   ])
  

# VehicleType.create!([
#   { name: "Bus", capacity_weight: 3500, capacity_volume: 12, max_speed: 90, price_per_km: 1.5 },
#   { name: "Ciężarówka solo", capacity_weight: 18000, capacity_volume: 50, max_speed: 80, price_per_km: 4.0 },
#   { name: "Ciężarówka z naczepą", capacity_weight: 24000, capacity_volume: 90, max_speed: 80, price_per_km: 4.5 },
#   { name: "Samochód osobowy", capacity_weight: 500, capacity_volume: 1.5, max_speed: 110, price_per_km: 0.8 }
# ])

# bus = VehicleType.find_by(name: "Bus")
# truck_solo = VehicleType.find_by(name: "Ciężarówka solo")
# truck_trailer = VehicleType.find_by(name: "Ciężarówka z naczepą")
# car = VehicleType.find_by(name: "Samochód osobowy")

# # Pobranie kategorii prawa jazdy
# b = LicenseCategory.find_by(name: "B")
# c = LicenseCategory.find_by(name: "C")
# ce = LicenseCategory.find_by(name: "C+E") 

# # Przypisanie wymaganych kategorii
# bus.license_categories << b unless bus.license_categories.include?(b)
# truck_solo.license_categories << c unless truck_solo.license_categories.include?(c)
# truck_trailer.license_categories << ce unless truck_trailer.license_categories.include?(ce)
# car.license_categories << b unless car.license_categories.include?(b)