import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="vehicle-suggest-map"
export default class extends Controller {
  static values = {
    pickupLat: Number,
    pickupLon: Number,
    vehicles: Array,
    orsApiKey: String,
  };

  connect() {
    setTimeout(() => this.initMap(), 2);
  }

  initMap() {
    const pickupLat = this.pickupLatValue || 52.2297;
    const pickupLon = this.pickupLonValue || 21.0122;
    const vehicles = this.vehiclesValue || [];

    this.map = L.map(this.element).setView([pickupLat, pickupLon], 6);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap contributors",
    }).addTo(this.map);

    //Pick-up point
    this.pickupMarker = L.marker([pickupLat, pickupLon])
      .addTo(this.map)
      .bindPopup("📦 Punkt odbioru");

    this.currentRoute = null;
    this.currentPopup = null;

    // Vehicle markers with registration number
    vehicles.forEach((v) => {
      if (v.lat && v.lon) {
        const registration = v.name || "Pojazd";

        const divIcon = L.divIcon({
          className: "vehicle-label",
          html: `<div class="vehicle-marker">${registration}</div>`,
          iconSize: [80, 30],
          iconAnchor: [40, 15],
        });

        const marker = L.marker([v.lat, v.lon], {
          icon: divIcon,
          title: registration,
        }).addTo(this.map);

        marker.on("click", () => {
          this.drawRoute(v, pickupLon, pickupLat);
        });
      }
    });

    const allPoints = [
      [pickupLat, pickupLon],
      ...vehicles.map((v) => [v.lat, v.lon]),
    ].filter(([lat, lon]) => lat && lon);

    if (allPoints.length > 1) {
      const bounds = L.latLngBounds(allPoints);
      this.map.fitBounds(bounds, { padding: [40, 40] });
    }
  }

  drawRoute(vehicle, pickupLon, pickupLat) {
    if (this.currentRoute) {
      this.map.removeLayer(this.currentRoute);
      this.currentRoute = null;
    }
    if (this.currentPopup) {
      this.map.closePopup(this.currentPopup);
      this.currentPopup = null;
    }

    if (!this.orsApiKeyValue) {
      console.warn("Brak klucza ORS_API_KEY");
      return;
    }

    const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${this.orsApiKeyValue}&start=${vehicle.lon},${vehicle.lat}&end=${pickupLon},${pickupLat}`;

    fetch(url)
      .then((res) => res.json())
      .then((data) => {
        if (!data.features || data.features.length === 0) return;

        const feature = data.features[0];
        const coords = feature.geometry.coordinates.map((c) => [c[1], c[0]]);
        const summary = feature.properties.summary;

        // Distance in km, time in minutes
        const distanceKm = (summary.distance / 1000).toFixed(1);
        const durationMin = Math.round(summary.duration / 60);

        // Add a line
        this.currentRoute = L.polyline(coords, {
          color: "green",
          weight: 4,
          opacity: 0.8,
        }).addTo(this.map);

        // Adjust view
        this.map.fitBounds(this.currentRoute.getBounds(), {
          padding: [40, 40],
        });

        // Add a popup with route info at the pickup point
        this.currentPopup = L.popup()
          .setLatLng([pickupLat, pickupLon])
          .setContent(
            `
            <div style="font-size:14px;">
              <strong>Trasa z:</strong> ${vehicle.name}<br>
              🚗 <strong>Dystans:</strong> ${distanceKm} km<br>
              ⏱️ <strong>Czas:</strong> ${durationMin} min
            </div>
          `
          )
          .openOn(this.map);
      })
      .catch((err) => console.error("Błąd ORS:", err));
  }
}
