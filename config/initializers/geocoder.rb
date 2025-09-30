Geocoder.configure(
    timeout: 5,
    units: :km,
    lookup: :nominatim, # darmowy serwis OpenStreetMap
    http_headers: { "User-Agent" => "transport_app/1.0" }
  )
  