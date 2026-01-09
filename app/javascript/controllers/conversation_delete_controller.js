import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { id: Number }

  confirm(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!confirm("Czy na pewno chcesz usunąć czat?")) return

    fetch(`/messages/delete_conversation/${this.idValue}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document
          .querySelector("meta[name='csrf-token']")
          .content
      }
    }).then(() => {
      // usuń z listy (optymistycznie)
      this.element.closest(".whatsapp-conversation")?.remove()

      // jeśli był aktywny czat → wyczyść okno
      const frame = document.getElementById("chat")
      if (frame) frame.innerHTML = ""
    })
  }
}
