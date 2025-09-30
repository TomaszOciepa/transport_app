import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autocomplete"
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
    if (this.hasPickupTarget) {
      const pickupAutocomplete = new google.maps.places.Autocomplete(
        this.pickupTarget,
        {
          componentRestrictions: { country: "pl" },
        }
      );
      pickupAutocomplete.addListener("place_changed", () => {
        const place = pickupAutocomplete.getPlace();
        if (place.geometry) {
          this.pickupLatTarget.value = place.geometry.location.lat();
          this.pickupLonTarget.value = place.geometry.location.lng();
        }
      });
    }

    if (this.hasDeliveryTarget) {
      const deliveryAutocomplete = new google.maps.places.Autocomplete(
        this.deliveryTarget,
        {
          componentRestrictions: { country: "pl" },
        }
      );
      deliveryAutocomplete.addListener("place_changed", () => {
        const place = deliveryAutocomplete.getPlace();
        if (place.geometry) {
          this.deliveryLatTarget.value = place.geometry.location.lat();
          this.deliveryLonTarget.value = place.geometry.location.lng();
        }
      });
    }
  }
}
