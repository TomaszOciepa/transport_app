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
    this.isPickupValid = false;
    this.isDeliveryValid = false;
    this.initAutocomplete();
  }

  initAutocomplete() {
    // --- Pickup Autocomplete ---
    if (this.hasPickupTarget) {
      const pickupAutocomplete = new google.maps.places.Autocomplete(
        this.pickupTarget
      );
      pickupAutocomplete.addListener("place_changed", () => {
        const place = pickupAutocomplete.getPlace();
        if (place.geometry) {
          this.pickupLatTarget.value = place.geometry.location.lat();
          this.pickupLonTarget.value = place.geometry.location.lng();
          this.isPickupValid = true;
          this.clearFieldError(this.pickupTarget);
        } else {
          this.isPickupValid = false;
        }
      });
      this.pickupTarget.addEventListener("input", () => {
        this.isPickupValid = false;
      });
    }

    // --- Delivery Autocomplete ---
    if (this.hasDeliveryTarget) {
      const deliveryAutocomplete = new google.maps.places.Autocomplete(
        this.deliveryTarget
      );
      deliveryAutocomplete.addListener("place_changed", () => {
        const place = deliveryAutocomplete.getPlace();
        if (place.geometry) {
          this.deliveryLatTarget.value = place.geometry.location.lat();
          this.deliveryLonTarget.value = place.geometry.location.lng();
          this.isDeliveryValid = true;
          this.clearFieldError(this.deliveryTarget);
        } else {
          this.isDeliveryValid = false;
        }
      });
      this.deliveryTarget.addEventListener("input", () => {
        this.isDeliveryValid = false;
      });
    }

    // --- Form validation ---
    const form = this.element.querySelector("form");
    if (form) {
      form.addEventListener("submit", (event) => {
        let firstError = null;

        if (!this.isPickupValid) {
          event.preventDefault();
          this.showFieldError(
            this.pickupTarget,
            "Proszę wybrać poprawny adres odbioru z sugestii."
          );
          if (!firstError) firstError = this.pickupTarget;
        } else {
          this.clearFieldError(this.pickupTarget);
        }

        if (!this.isDeliveryValid) {
          event.preventDefault();
          this.showFieldError(
            this.deliveryTarget,
            "Proszę wybrać poprawny adres dostawy z sugestii."
          );
          if (!firstError) firstError = this.deliveryTarget;
        } else {
          this.clearFieldError(this.deliveryTarget);
        }

        if (firstError) {
          firstError.scrollIntoView({ behavior: "smooth", block: "center" });
          firstError.focus();
        }
      });
    }
  }

  showFieldError(input, message) {
    this.clearFieldError(input);
    const error = document.createElement("div");
    error.className = "invalid-feedback d-block";
    error.textContent = message;
    input.parentNode.appendChild(error);
    input.classList.add("is-invalid");
  }

  clearFieldError(input) {
    const error = input.parentNode.querySelector(".invalid-feedback");
    if (error) error.remove();
    input.classList.remove("is-invalid");
  }
}
