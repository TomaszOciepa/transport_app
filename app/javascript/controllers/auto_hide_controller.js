import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { timeout: Number };

  connect() {
    setTimeout(() => {
      this.unlockForm();
      this.element.remove();
    }, this.timeoutValue || 3000);
  }

  unlockForm() {
    const form = document.querySelector("form.chat-input-area");
    if (!form) return;

    // 🔓 Turbo-safe reset
    form.reset();

    // 🔓 odblokuj przyciski (jeśli Turbo je zablokowało)
    form.querySelectorAll("button, input, textarea").forEach((el) => {
      el.disabled = false;
      el.removeAttribute("aria-disabled");
    });

    console.debug("🟢 Formularz odblokowany po błędzie");
  }
}
