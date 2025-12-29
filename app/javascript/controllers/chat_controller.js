import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textarea",
    "messagesBox",
    "messagesFrame",
    "chatWrapper",
    "filePreview",
    "attachButton",
    "mediaInput"
  ]

  connect() {
    this.markReadInFlight = false
    this.observer = null

    // Bindowane handlery (żeby móc je zdejmować)
    this._onTurboLoad = this.onTurboLoad.bind(this)
    this._onTurboFrameLoad = this.onTurboFrameLoad.bind(this)
    this._onDocClick = this.onDocClick.bind(this)
    this._onSubmitEnd = this.onSubmitEnd.bind(this)

    document.addEventListener("turbo:load", this._onTurboLoad)
    document.addEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.addEventListener("click", this._onDocClick)
    document.addEventListener("turbo:submit-end", this._onSubmitEnd)

    // Pierwszy init (np. przy wejściu od razu w aktywną rozmowę)
    this.markActiveFromUrl()
    this.initChat()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this._onTurboLoad)
    document.removeEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.removeEventListener("click", this._onDocClick)
    document.removeEventListener("turbo:submit-end", this._onSubmitEnd)

    this.disconnectObserver()
    this.unbindTextareaEvents()
  }

  // ================= TURBO EVENTS =================

  onTurboLoad() {
    this.markActiveFromUrl()
    this.initChat()
  }

  onTurboFrameLoad(e) {
    // Po przeładowaniu prawego panelu musimy ponownie spiąć textarea/scroll/observer
    if (e.target && e.target.id === "chat_panel") {
      this.markActiveFromUrl()
      this.initChat()
    }
  }

  // ================= CLICK: ACTIVE CHAT + URL =================

  onDocClick(e) {
    const link = e.target.closest(".chat-link")
    if (!link) return

    const groupId = link.dataset.groupId
    if (!groupId) return

    // Update URL
    const newUrl = new URL(window.location)
    newUrl.searchParams.set("group_id", groupId)
    window.history.pushState({}, "", newUrl)

    // Active state in left column
    document.querySelectorAll(".chat-item.active")
      .forEach(el => el.classList.remove("active"))

    const item = document.querySelector(`.chat-item[data-group-id='${groupId}']`)
    if (item) item.classList.add("active")
  }

  markActiveFromUrl() {
    const params = new URLSearchParams(window.location.search)
    const groupId = params.get("group_id")
    if (!groupId) return

    document.querySelectorAll(".chat-item.active")
      .forEach(el => el.classList.remove("active"))

    const item = document.querySelector(`.chat-item[data-group-id='${groupId}']`)
    if (item) item.classList.add("active")
  }

  // ================= SUBMIT END: CLEAR INPUTS =================

  onSubmitEnd(e) {
    const form = e.target
    if (!form || !form.classList || !form.classList.contains("chat-input-area")) return

    // textarea
    const textarea = form.querySelector("#whatsappMessageBody")
    if (textarea) {
      textarea.value = ""
      textarea.style.height = ""
      textarea.focus()
    }

    // file reset
    const preview = form.querySelector(".file-preview")
    const button = form.querySelector(".attach-btn")
    const input = form.querySelector("#media-input")

    if (preview) {
      preview.textContent = ""
      preview.classList.add("d-none")
    }

    if (button) {
      button.innerHTML = `<i class="bi bi-plus-lg"></i>`
      button.classList.remove("file-selected")
    }

    if (input) {
      input.value = ""
    }
  }

  // ================= CHAT INIT =================

  initChat() {
    // Targets mogą nie istnieć (np. brak aktywnej rozmowy)
    if (!this.hasTextareaTarget || !this.hasMessagesBoxTarget || !this.hasMessagesFrameTarget) {
      this.disconnectObserver()
      this.unbindTextareaEvents()
      return
    }

    // Żeby nie dublować eventów po frame-load
    this.unbindTextareaEvents()

    // ENTER = SEND
    this._onTextareaKeydown = (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        // requestSubmit działa lepiej z Turbo niż submit()
        this.textareaTarget.form?.requestSubmit()
      }
    }
    this.textareaTarget.addEventListener("keydown", this._onTextareaKeydown)

    // MARK AS READ na focus textarea
    this._onTextareaFocus = () => {
      const groupId = this.getActiveGroupIdFromDom()
      this.markChatAsRead(groupId)
    }
    this.textareaTarget.addEventListener("focus", this._onTextareaFocus)

    // SCROLL + observer
    this.disconnectObserver()

    const scrollToBottom = () => {
      this.messagesBoxTarget.scrollTop = this.messagesBoxTarget.scrollHeight
    }

    this.observer = new MutationObserver(scrollToBottom)
    this.observer.observe(this.messagesFrameTarget, { childList: true, subtree: true })

    // initial scroll
    setTimeout(scrollToBottom, 50)
  }

  unbindTextareaEvents() {
    if (this.hasTextareaTarget) {
      if (this._onTextareaKeydown) {
        this.textareaTarget.removeEventListener("keydown", this._onTextareaKeydown)
      }
      if (this._onTextareaFocus) {
        this.textareaTarget.removeEventListener("focus", this._onTextareaFocus)
      }
    }
    this._onTextareaKeydown = null
    this._onTextareaFocus = null
  }

  disconnectObserver() {
    if (this.observer) {
      try { this.observer.disconnect() } catch (_) {}
      this.observer = null
    }
  }

  // ================= MARK AS READ =================

  getActiveGroupIdFromDom() {
    const input = document.querySelector("input[name='whatsapp_group_id']")
    return input ? input.value : null
  }

  markChatAsRead(groupId) {
    if (!groupId) return
    if (this.markReadInFlight) return

    this.markReadInFlight = true

    fetch(`/dispatcher/messages/${groupId}/mark_as_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      }
    })
      .catch(() => {})
      .finally(() => {
        this.markReadInFlight = false
      })
  }
}
