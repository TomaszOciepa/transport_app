import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { driverId: Number }

  open() {
    fetch("/messages/ensure_driver_conversation", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector("meta[name='csrf-token']")
          .content
      },
      body: JSON.stringify({
        driver_id: this.driverIdValue
      })
    })
      .then(r => r.json())
      .then(({ conversation_id }) => {
        // 1️⃣ zapisz jako aktywną rozmowę (spójne z sidebar)
        sessionStorage.setItem(
          "activeConversationId",
          conversation_id
        )

        // 2️⃣ otwórz czat w turbo-frame
        const frame = document.getElementById("chat")
        if (frame) {
          frame.src = `/messages?conversation_id=${conversation_id}`
        }

        // 3️⃣ aktywuj rozmowę w sidebarze (jeśli już istnieje)
        document
          .querySelectorAll(".whatsapp-conversation.active")
          .forEach(el => el.classList.remove("active"))

        const el = document.querySelector(
          `.whatsapp-conversation[data-conversation-id="${conversation_id}"]`
        )
        el?.classList.add("active")

        // 4️⃣ 🔔 POWIADOM MENU, ŻE WYBRANO KIEROWCĘ (zamyka popup)
        window.dispatchEvent(
          new CustomEvent("driver:selected")
        )
      })
  }
}
