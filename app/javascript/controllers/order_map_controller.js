import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="order-map"
export default class extends Controller {
  static values = {
    pickupLat: Number,
    pickupLon: Number,
    deliveryLat: Number,
    deliveryLon: Number,
    orsApiKey: String,
  };

  connect() {
    setTimeout(() => this.initMap(), 2);
  }

  initMap() {
    const pickupLat = this.pickupLatValue || 52.2297;
    const pickupLon = this.pickupLonValue || 21.0122;
    const deliveryLat = this.deliveryLatValue;
    const deliveryLon = this.deliveryLonValue;

    const map = L.map(this.element).setView([pickupLat, pickupLon], 6);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap contributors",
    }).addTo(map);

    L.marker([pickupLat, pickupLon]).addTo(map).bindPopup("Odbiór").openPopup();
    if (deliveryLat && deliveryLon) {
      L.marker([deliveryLat, deliveryLon]).addTo(map).bindPopup("Dostawa");
    }

    if (deliveryLat && deliveryLon && this.orsApiKeyValue) {
      const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${this.orsApiKeyValue}&start=${pickupLon},${pickupLat}&end=${deliveryLon},${deliveryLat}`;

      fetch(url)
        .then((res) => res.json())
        .then((data) => {
          if (!data.features || data.features.length === 0) return;
          const coords = data.features[0].geometry.coordinates.map((c) => [
            c[1],
            c[0],
          ]);
          L.polyline(coords, { color: "blue", weight: 5 }).addTo(map);
          map.fitBounds(coords);
        })
        .catch((err) => console.error("Błąd ORS:", err));
    }
  }
}
