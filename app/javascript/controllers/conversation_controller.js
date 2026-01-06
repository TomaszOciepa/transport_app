import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const savedId = sessionStorage.getItem("activeConversationId")

    // reload / entry
    // We do NOT clear the badge
    if (savedId && this.element.dataset.conversationId === savedId) {
      this.activate()
      this.open()
    }
  }

  select(event) {
    event.preventDefault()

    const conversationId = this.element.dataset.conversationId

    // 1 UX – active chat
    sessionStorage.setItem("activeConversationId", conversationId)
    this.activate()

   // 2 OPTIMISTIC UI – remove badge IMMEDIATELY
    this.removeBadge()

   // 3 Backend – lasting truth
    this.markAsRead(conversationId)

    // 4 Open chat
    this.open()
  }

  activate() {
    document
      .querySelectorAll(".whatsapp-conversation.active")
      .forEach(el => el.classList.remove("active"))

    this.element.classList.add("active")
  }

  open() {
    const frame = document.getElementById("chat")
    if (!frame) return

    frame.src = this.element.href
  }

  // =========================
  // Optimistic UI helpers
  // =========================
  removeBadge() {
    const badge = this.element.querySelector(".whatsapp-unread-badge")
    if (badge) badge.remove()
  }

  // =========================
  // Backend
  // =========================
  markAsRead(conversationId) {
    fetch(`/messages/mark_as_read/${conversationId}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document
          .querySelector("meta[name='csrf-token']")
          .content
      }
    })
  }
}
