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
        // 1️⃣ zapisz jako aktywną
        sessionStorage.setItem(
          "activeConversationId",
          conversation_id
        )

        // 2️⃣ otwórz turbo-frame jak normalny czat
        const frame = document.getElementById("chat")
        if (frame) {
          frame.src = `/messages?conversation_id=${conversation_id}`
        }

        // 3️⃣ zaznacz w sidebarze
        document
          .querySelectorAll(".whatsapp-conversation.active")
          .forEach(el => el.classList.remove("active"))

        const el = document.querySelector(
          `[data-conversation-id="${conversation_id}"]`
        )
        el?.classList.add("active")
      })
  }
}
