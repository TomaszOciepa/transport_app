class VehicleSuggestMapComponent < ViewComponent::Base
    def initialize(order:, vehicles:)
      @order = order
      @vehicles = vehicles
      @ors_api_key = ENV["ORS_API_KEY"]
    end
  
    # Wyliczamy "aktualne" pozycje pojazdów (czyli miejsce ostatniej dostawy lub domyślne)
    def vehicles_positions
      @vehicles.map do |v|
        last_order = v.orders
                      .joins(:order_vehicles)
                      .where(order_vehicles: { current: true })
                      .where.not(delivery_lat: nil, delivery_lon: nil, delivery_date: nil)
                      .where("delivery_date < ?", @order.pickup_date)
                      .order(delivery_date: :desc)
                      .first
  
        lat, lon = if last_order
                     [last_order.delivery_lat, last_order.delivery_lon]
                   else
                     [54.399063, 18.6675238] # np. baza pojazdów w Gdańsku
                   end
  
        {
          id: v.id,
          name: v.registration_number,
          lat: lat,
          lon: lon
        }
      end
    end
  end
  