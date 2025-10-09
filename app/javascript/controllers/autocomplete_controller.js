import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pickup", "delivery"];

  connect() {
    this.pickupSelected = false;
    this.deliverySelected = false;

    const form = this.element;

    // submit: block if no hint selected
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

    // we set flags when selecting Mapbox suggestions
    if (this.hasPickupTarget) {
      this.pickupTarget.addEventListener("retrieve", () => {
        this.pickupSelected = true;
        this.clearValidation(this.pickupTarget);
      });
    }

    if (this.hasDeliveryTarget) {
      this.deliveryTarget.addEventListener("retrieve", () => {
        this.deliverySelected = true;
        this.clearValidation(this.deliveryTarget);
      });
    }
  }

  showValidationError(element, message) {
    element.classList.add("is-invalid");

    if (
      !element.nextElementSibling ||
      !element.nextElementSibling.classList.contains("invalid-feedback")
    ) {
      const feedback = document.createElement("div");
      feedback.classList.add("invalid-feedback");
      feedback.textContent = message;
      element.after(feedback);
    } else {
      element.nextElementSibling.textContent = message;
    }

    element.scrollIntoView({ behavior: "smooth", block: "center" });
  }

  clearValidation(element) {
    element.classList.remove("is-invalid");
    if (
      element.nextElementSibling &&
      element.nextElementSibling.classList.contains("invalid-feedback")
    ) {
      element.nextElementSibling.remove();
    }
  }
}
