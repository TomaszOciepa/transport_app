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

    // bindowane handlery
    this._onTurboLoad = this.onTurboLoad.bind(this)
    this._onTurboFrameLoad = this.onTurboFrameLoad.bind(this)
    this._onDocClick = this.onDocClick.bind(this)
    this._onSubmitEnd = this.onSubmitEnd.bind(this)

    document.addEventListener("turbo:load", this._onTurboLoad)
    document.addEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.addEventListener("click", this._onDocClick)
    document.addEventListener("turbo:submit-end", this._onSubmitEnd)

    this.markActiveFromUrl()
    this.initChat()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this._onTurboLoad)
    document.removeEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.removeEventListener("click", this._onDocClick)
    document.removeEventListener("turbo:submit-end", this._onSubmitEnd)

    this.cleanup()
  }

  // ================= TURBO =================

  onTurboLoad() {
    this.markActiveFromUrl()
    this.initChat()
  }

  onTurboFrameLoad(e) {
    if (e.target && e.target.id === "chat_panel") {
      this.markActiveFromUrl()
      this.initChat()
    }
  }

  // ================= ACTIVE CHAT (LEFT) =================

  onDocClick(e) {
    const link = e.target.closest(".chat-link")
    if (!link) return

    const groupId = link.dataset.groupId
    if (!groupId) return

    const newUrl = new URL(window.location)
    newUrl.searchParams.set("group_id", groupId)
    window.history.pushState({}, "", newUrl)

    document.querySelectorAll(".chat-item.active")
      .forEach(el => el.classList.remove("active"))

    const item = document.querySelector(
      `.chat-item[data-group-id='${groupId}']`
    )
    if (item) item.classList.add("active")
  }

  markActiveFromUrl() {
    const params = new URLSearchParams(window.location.search)
    const groupId = params.get("group_id")
    if (!groupId) return

    document.querySelectorAll(".chat-item.active")
      .forEach(el => el.classList.remove("active"))

    const item = document.querySelector(
      `.chat-item[data-group-id='${groupId}']`
    )
    if (item) item.classList.add("active")
  }

  // ================= FORM SUBMIT =================

  onSubmitEnd(e) {
    const form = e.target
    if (!form?.classList?.contains("chat-input-area")) return

    const textarea = form.querySelector("#whatsappMessageBody")
    if (textarea) {
      textarea.value = ""
      textarea.style.height = ""
      textarea.focus()
    }

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
    if (!this.hasTextareaTarget || !this.hasMessagesBoxTarget || !this.hasMessagesFrameTarget) {
      this.cleanup()
      return
    }

    this.cleanup()

    // ENTER = SEND
    this._onTextareaKeydown = (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        this.textareaTarget.form?.requestSubmit()
      }
    }
    this.textareaTarget.addEventListener("keydown", this._onTextareaKeydown)

    // helper: czy user jest na dole
    const isAtBottom = () => {
      const el = this.messagesBoxTarget
      return el.scrollTop + el.clientHeight >= el.scrollHeight - 10
    }

    const scrollToBottom = () => {
      this.messagesBoxTarget.scrollTop = this.messagesBoxTarget.scrollHeight
    }

    // MutationObserver — reaguje na nowe wiadomości
    this.observer = new MutationObserver(() => {
      if (isAtBottom()) {
        scrollToBottom()
        const groupId = this.getActiveGroupIdFromDom()
        this.markChatAsRead(groupId)
      }
    })

    this.observer.observe(this.messagesFrameTarget, {
      childList: true,
      subtree: true
    })

    // scroll listener — odczyt dopiero gdy user dojedzie na dół
    this._onMessagesScroll = () => {
      if (isAtBottom()) {
        const groupId = this.getActiveGroupIdFromDom()
        this.markChatAsRead(groupId)
      }
    }
    this.messagesBoxTarget.addEventListener("scroll", this._onMessagesScroll)

    // initial scroll + ewentualny read
    setTimeout(() => {
      scrollToBottom()
      if (isAtBottom()) {
        const groupId = this.getActiveGroupIdFromDom()
        this.markChatAsRead(groupId)
      }
    }, 80)
  }

  cleanup() {
    if (this._onTextareaKeydown && this.hasTextareaTarget) {
      this.textareaTarget.removeEventListener("keydown", this._onTextareaKeydown)
    }
    this._onTextareaKeydown = null

    if (this._onMessagesScroll && this.hasMessagesBoxTarget) {
      this.messagesBoxTarget.removeEventListener("scroll", this._onMessagesScroll)
    }
    this._onMessagesScroll = null

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
