import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const savedId = sessionStorage.getItem("activeConversationId")

    // jeśli to jest reload / wejście
    if (savedId && this.element.dataset.conversationId === savedId) {
      this.activate()
      this.open()
    }
  }

  select(event) {
    // zapisz kliknięty czat
    sessionStorage.setItem(
      "activeConversationId",
      this.element.dataset.conversationId
    )

    this.activate()
  }

  activate() {
    document
      .querySelectorAll(".whatsapp-conversation.active")
      .forEach(el => el.classList.remove("active"))

    this.element.classList.add("active")
  }

  open() {
    // ręcznie załaduj czat do turbo-frame
    const frame = document.getElementById("chat")
    if (!frame) return

    frame.src = this.element.href
  }
}
