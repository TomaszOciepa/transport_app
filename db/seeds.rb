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