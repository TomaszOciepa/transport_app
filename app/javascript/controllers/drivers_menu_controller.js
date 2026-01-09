import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "search", "list", "item"]

  connect() {
    this.handleOutsideClick = this.outsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.hasAttribute("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.removeAttribute("hidden")

    // focus input on open
    requestAnimationFrame(() => {
      this.searchTarget?.focus()
    })
  }

  close() {
    this.menuTarget.setAttribute("hidden", "")
    this.resetFilter()
  }

  outsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // 🔍 FILTER LOGIC
  filter() {
    const query = this.searchTarget.value.toLowerCase().trim()

    this.itemTargets.forEach(item => {
      const text = item.dataset.searchText
      item.hidden = !text.includes(query)
    })
  }

  resetFilter() {
    if (!this.searchTarget) return

    this.searchTarget.value = ""
    this.itemTargets.forEach(item => {
      item.hidden = false
    })
  }

  openConversation(event) {
    const driverId = event.currentTarget.dataset.driverId
  
    fetch("/messages/ensure_driver_conversation", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector("meta[name='csrf-token']")
          .content
      },
      body: JSON.stringify({ driver_id: driverId })
    })
      .then(r => r.json())
      .then(data => {
        const conversationId = data.conversation_id
  
        // 1️⃣ sessionStorage (tak jak sidebar)
        sessionStorage.setItem("activeConversationId", conversationId)
  
        // 2️⃣ aktywacja wizualna (jeśli istnieje w sidebar)
        document
          .querySelectorAll(".whatsapp-conversation.active")
          .forEach(el => el.classList.remove("active"))
  
        const el = document.querySelector(
          `.whatsapp-conversation[data-conversation-id="${conversationId}"]`
        )
        if (el) el.classList.add("active")
  
        // 3️⃣ otwarcie czatu (JEDYNA poprawna droga)
        const frame = document.getElementById("chat")
        if (frame) {
          frame.src = `/messages?conversation_id=${conversationId}`
        }
  
        // 4️⃣ zamknij menu
        this.close()
      })
  }
  
}
