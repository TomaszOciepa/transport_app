import { Controller } from "@hotwired/stimulus";

// Stimulus controller dla Mapbox Search
export default class extends Controller {
  static targets = [
    "pickup",
    "pickupLat",
    "pickupLon",
    "delivery",
    "deliveryLat",
    "deliveryLon",
  ];

  connect() {
    // Pickup
    this.pickupTarget.addEventListener("retrieve", (e) => {
      const feature = e.detail.features[0];
      this.pickupLatTarget.value = feature.geometry.coordinates[1];
      this.pickupLonTarget.value = feature.geometry.coordinates[0];
    });

    // Delivery
    this.deliveryTarget.addEventListener("retrieve", (e) => {
      const feature = e.detail.features[0];
      this.deliveryLatTarget.value = feature.geometry.coordinates[1];
      this.deliveryLonTarget.value = feature.geometry.coordinates[0];
    });
  }
}
