VehicleType.create!([
    { name: "Samochód osobowy", capacity: 500, max_speed: 180 },
    { name: "Bus", capacity: 2000, max_speed: 140 },
    { name: "Tir", capacity: 20000, max_speed: 80 },
    { name: "Van", capacity: 800, max_speed: 160 }
  ])
  
  # Seedy dla ServiceType (typy usług)
  ServiceType.create!([
    { name: "Standard"},
    { name: "Express"}
  ])