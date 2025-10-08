VehicleType.create!([
  { name: "Samochód osobowy", capacity: 500, max_speed: 110, price_per_km: 1.20 },
  { name: "Bus", capacity: 2000, max_speed: 95, price_per_km: 2.50 },
  { name: "Tir", capacity: 20000, max_speed: 80, price_per_km: 4.00 },
  { name: "Van", capacity: 800, max_speed: 100, price_per_km: 2.00 }
])

  
  ServiceType.create!([
    { name: "Standard", multiplier: 1.0 },
    { name: "Express", multiplier: 1.5 }
  ])



  User.create!([
    {email: 'client@example.com', password: 'password123', password_confirmation: 'password123', role: :client},
    { email: 'dispatcher@example.com', password: 'password123', password_confirmation: 'password123', role: :dispatcher},
    {email: 'admin@example.com', password: 'password123', password_confirmation: 'password123', role: :admin}
  ])

  Driver.create!([
    {
      first_name: "Jan",
      last_name: "Kowalski",
      email: "jan.kowalski@example.com",
      phone: "600123456",
      license_category: "B",
      birth_year: 1985,
      available_from: "08:00",
      available_to: "18:00",
      status: :available
    },
    {
      first_name: "Anna",
      last_name: "Nowak",
      email: "anna.nowak@example.com",
      phone: "601987654",
      license_category: "C",
      birth_year: 1990,
      available_from: "07:00",
      available_to: "16:00",
      status: :available
    },
    {
      first_name: "Piotr",
      last_name: "Wiśniewski",
      email: "piotr.wisniewski@example.com",
      phone: "602555777",
      license_category: "B,C",
      birth_year: 1982,
      available_from: "09:00",
      available_to: "17:00",
      status: :off_duty
    }
  ])
  

Vehicle.create!([
  {
    brand: "Volvo",
    registration_number: "GD12345",
    vehicle_type_id: VehicleType.find_by(name: "Samochód osobowy")&.id,
    status: :available,
    required_license: "B"
  },
  {
    brand: "Scania",
    registration_number: "GD54321",
    vehicle_type_id: VehicleType.find_by(name: "Tir")&.id,
    status: :available,
    required_license: "C"
  },
  {
    brand: "Mercedes",
    registration_number: "GD11223",
    vehicle_type_id: VehicleType.find_by(name: "Bus")&.id,
    status: :maintenance,
    required_license: "B"
  },
  {
    brand: "MAN",
    registration_number: "GD44556",
    vehicle_type_id: VehicleType.find_by(name: "Van")&.id,
    status: :available,
    required_license: "C"
  }
])
