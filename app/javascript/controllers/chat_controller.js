import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textarea",
    "messagesBox",
    "messagesFrame",
    "chatWrapper",
    "filePreview",
    "attachButton",
    "mediaInput",
    "newMessageIndicator"
  ]

  connect() {
    this.markReadInFlight = false
    this.observer = null
    this.suppressIndicatorUntil = 0

    // turbo handlers
    this._onTurboLoad = this.onTurboLoad.bind(this)
    this._onTurboFrameLoad = this.onTurboFrameLoad.bind(this)
    this._onBeforeFrameRender = this.onBeforeFrameRender.bind(this)
    this._onSubmitEnd = this.onSubmitEnd.bind(this)

    document.addEventListener("turbo:load", this._onTurboLoad)
    document.addEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.addEventListener("turbo:before-frame-render", this._onBeforeFrameRender)
    document.addEventListener("turbo:submit-end", this._onSubmitEnd)

    this.markActiveFromUrl()
    this.initChat()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this._onTurboLoad)
    document.removeEventListener("turbo:frame-load", this._onTurboFrameLoad)
    document.removeEventListener("turbo:before-frame-render", this._onBeforeFrameRender)
    document.removeEventListener("turbo:submit-end", this._onSubmitEnd)

    this.cleanup()
  }

  // ================= TURBO =================

  onTurboLoad() {
    this.markActiveFromUrl()
    this.initChat()
  }

  onTurboFrameLoad(e) {
    if (e.target?.id === "chat_panel") {
      this.markActiveFromUrl()
      this.initChat()
    }
  }

  // 🔥 KLUCZOWE: cleanup PRZED swapem frame
  onBeforeFrameRender(e) {
    if (e.target?.id === "chat_panel") {
      this.cleanup()
    }
  }

  // ================= ACTIVE CHAT =================

  markActiveFromUrl() {
    const groupId = new URLSearchParams(window.location.search).get("group_id")
  
    // 🔥 ZAWSZE resetuj stary stan
    document.querySelectorAll(".chat-item.active")
      .forEach(el => el.classList.remove("active"))
  
    // jeśli nie ma group_id → NIE zaznaczaj nic
    // backend już zrobił to poprawnie w HTML
    if (!groupId) return
  
    const item = document.querySelector(`.chat-item[data-group-id='${groupId}']`)
    if (item) item.classList.add("active")
  }
  

  // ================= FORM SUBMIT =================

  onSubmitEnd(e) {
    const form = e.target
    if (!form?.classList?.contains("chat-input-area")) return

    this.suppressIndicatorUntil = Date.now() + 800
    this.hideNewMessageIndicator()
    this.scrollToBottom()

    // 🔥 DOMKNIĘCIE CYKLU OBSERVERA
    requestAnimationFrame(() => {
    if (this.observer) {
        try {
        this.observer.disconnect()
        this.observer.observe(this.messagesFrameTarget, {
            childList: true,
            subtree: true
        })
        } catch (_) {}
    }
    })


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

    if (input) input.value = ""
  }

  // ================= CHAT INIT =================

  initChat() {
    if (!this.hasTextareaTarget || !this.hasMessagesBoxTarget || !this.hasMessagesFrameTarget) {
      this.cleanup()
      return
    }

    this.cleanup()
    this.hideNewMessageIndicator()

    this._onTextareaKeydown = (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        this.suppressIndicatorUntil = Date.now() + 800
        this.hideNewMessageIndicator()
        this.scrollToBottom()
        this.textareaTarget.form?.requestSubmit()
      }
    }
    this.textareaTarget.addEventListener("keydown", this._onTextareaKeydown)

    const isAtBottom = () => {
      const el = this.messagesBoxTarget
      return el.scrollTop + el.clientHeight >= el.scrollHeight - 10
    }

    // 🔥 MutationObserver — BEZ dead-locków
    this.observer = new MutationObserver((mutations) => {
      if (!document.body.contains(this.messagesFrameTarget)) return

      setTimeout(() => {
        if (Date.now() < this.suppressIndicatorUntil) {
          this.scrollToBottom()
          this.hideNewMessageIndicator()
          return
        }

        const addedOutgoing = mutations.some(m =>
          Array.from(m.addedNodes || []).some(node =>
            node instanceof HTMLElement &&
            (node.matches(".bubble.outgoing") || node.querySelector(".bubble.outgoing"))
          )
        )

        if (addedOutgoing) {
          this.scrollToBottom()
          this.hideNewMessageIndicator()
          return
        }

        if (isAtBottom()) {
          this.scrollToBottom()
          this.hideNewMessageIndicator()
          this.markChatAsRead(this.getActiveGroupIdFromDom())
        } else {
          this.showNewMessageIndicator()
        }
      }, 0)
    })

    this.observer.observe(this.messagesFrameTarget, { childList: true, subtree: true })

    this._onMessagesScroll = () => {
      if (isAtBottom()) {
        this.hideNewMessageIndicator()
        this.markChatAsRead(this.getActiveGroupIdFromDom())
      }
    }
    this.messagesBoxTarget.addEventListener("scroll", this._onMessagesScroll)

    setTimeout(() => {
      this.scrollToBottom()
      if (isAtBottom()) {
        this.markChatAsRead(this.getActiveGroupIdFromDom())
      }
    }, 80)
  }

  // ================= INDICATOR =================

  showNewMessageIndicator() {
    if (this.hasNewMessageIndicatorTarget) {
      this.newMessageIndicatorTarget.style.display = "block"
    }
  }

  hideNewMessageIndicator() {
    if (this.hasNewMessageIndicatorTarget) {
      this.newMessageIndicatorTarget.style.display = "none"
    }
  }

  scrollToBottom() {
    if (this.hasMessagesBoxTarget) {
      this.messagesBoxTarget.scrollTop = this.messagesBoxTarget.scrollHeight
    }
  }

  scrollToBottomFromIndicator() {
    this.scrollToBottom()
    this.hideNewMessageIndicator()
    this.markChatAsRead(this.getActiveGroupIdFromDom())
  }

  // ================= CLEANUP =================

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
    if (!groupId || this.markReadInFlight) return

    this.markReadInFlight = true

    fetch(`/dispatcher/messages/${groupId}/mark_as_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      }
    })
      .finally(() => {
        this.markReadInFlight = false
      })
  }
}
