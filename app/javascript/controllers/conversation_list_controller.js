import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const savedId = sessionStorage.getItem("activeConversationId")
    if (savedId) return

    const first = this.element.querySelector(".whatsapp-conversation")
    if (!first) return

    sessionStorage.setItem(
      "activeConversationId",
      first.dataset.conversationId
    )

    first.classList.add("active")

    const frame = document.getElementById("chat")
    if (frame) frame.src = first.href
  }
}
