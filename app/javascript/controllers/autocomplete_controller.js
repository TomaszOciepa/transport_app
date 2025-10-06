import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "pickup",
    "pickupLat",
    "pickupLon",
    "pickupCity",
    "pickupPostcode",
    "delivery",
    "deliveryLat",
    "deliveryLon",
    "deliveryCity",
    "deliveryPostcode",
  ];

  connect() {
    this.pickupSelected = false;
    this.deliverySelected = false;

    const form = this.element.querySelector("form");

    // submit
    form.addEventListener("submit", (e) => {
      this.clearValidation(this.pickupTarget);
      this.clearValidation(this.deliveryTarget);

      if (!this.pickupSelected) {
        e.preventDefault();
        this.showValidationError(
          this.pickupTarget,
          "Proszę wybrać adres odbioru z podpowiedzi."
        );
      }

      if (!this.deliverySelected) {
        e.preventDefault();
        this.showValidationError(
          this.deliveryTarget,
          "Proszę wybrać adres dostawy z podpowiedzi."
        );
      }
    });

    // we set flags when selecting a hint
    this.pickupTarget.addEventListener("retrieve", (e) =>
      this.handlePickupRetrieve(e)
    );
    this.deliveryTarget.addEventListener("retrieve", (e) =>
      this.handleDeliveryRetrieve(e)
    );
  }

  handlePickupRetrieve(e) {
    this.pickupSelected = true;
    const feature = e.detail.features[0];
    this.pickupLatTarget.value = feature.geometry.coordinates[1];
    this.pickupLonTarget.value = feature.geometry.coordinates[0];

    if (feature.context) {
      const place = feature.context.find((c) => c.id.includes("place"));
      const postcode = feature.context.find((c) => c.id.includes("postcode"));
      this.pickupCityTarget.value = place ? place.text : "";
      this.pickupPostcodeTarget.value = postcode ? postcode.text : "";
    }
    this.clearValidation(this.pickupTarget);
  }

  handleDeliveryRetrieve(e) {
    this.deliverySelected = true;
    const feature = e.detail.features[0];
    this.deliveryLatTarget.value = feature.geometry.coordinates[1];
    this.deliveryLonTarget.value = feature.geometry.coordinates[0];

    if (feature.context) {
      const place = feature.context.find((c) => c.id.includes("place"));
      const postcode = feature.context.find((c) => c.id.includes("postcode"));
      this.deliveryCityTarget.value = place ? place.text : "";
      this.deliveryPostcodeTarget.value = postcode ? postcode.text : "";
    }
    this.clearValidation(this.deliveryTarget);
  }

  showValidationError(inputElement, message) {
    inputElement.classList.add("is-invalid");
    if (
      !inputElement.nextElementSibling ||
      !inputElement.nextElementSibling.classList.contains("invalid-feedback")
    ) {
      const feedback = document.createElement("div");
      feedback.classList.add("invalid-feedback");
      feedback.textContent = message;
      inputElement.after(feedback);
    } else {
      inputElement.nextElementSibling.textContent = message;
    }

    // scroll to the error field
    inputElement.scrollIntoView({ behavior: "smooth", block: "center" });
  }

  clearValidation(inputElement) {
    inputElement.classList.remove("is-invalid");
    if (
      inputElement.nextElementSibling &&
      inputElement.nextElementSibling.classList.contains("invalid-feedback")
    ) {
      inputElement.nextElementSibling.remove();
    }
  }
}
