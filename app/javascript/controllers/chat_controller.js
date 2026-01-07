import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("[CHAT] connect", this.element)

    this.beforeFrameRender = this.handleBeforeFrameRender.bind(this)
    document.addEventListener(
      "turbo:before-frame-render",
      this.beforeFrameRender
    )

    requestAnimationFrame(() => {
      this.initializeScroll()
    })
  }

  disconnect() {
    console.log("[CHAT] disconnect")

    document.removeEventListener(
      "turbo:before-frame-render",
      this.beforeFrameRender
    )
  }

  // =========================
  // TURBO FRAME HOOK (DEBUG)
  // =========================
  handleBeforeFrameRender(event) {
    console.log("[CHAT] turbo:before-frame-render fired")

    const frame = event.target
    console.log("[CHAT] frame target:", frame)

    if (!frame || frame.id !== "chat") {
      console.log("[CHAT] ignored frame", frame?.id)
      return
    }

    console.log("[CHAT] processing chat frame")

    const currentSeparator = frame.querySelector(
      ".whatsapp-new-messages-separator"
    )

    console.log("[CHAT] current separator:", currentSeparator)

    if (!currentSeparator) {
      console.log("[CHAT] no separator in current frame")
      return
    }

    const newFrame = event.detail.newFrame
    console.log("[CHAT] newFrame:", newFrame)

    const willExist =
      newFrame.querySelector(".whatsapp-new-messages-separator")

    console.log("[CHAT] separator in new frame?", !!willExist)

    if (willExist) {
      console.log("[CHAT] separator persists, no fade-out")
      return
    }

    console.log("[CHAT] separator WILL BE REMOVED → FADE-OUT")

    const clone = currentSeparator.cloneNode(true)
    clone.classList.add("fade-out")

    currentSeparator.replaceWith(clone)

    console.log("[CHAT] clone inserted, waiting before remove")

    setTimeout(() => {
      console.log("[CHAT] removing clone after delay")
      clone.remove()
    }, 3000)
  }

  // =========================
  // Scroll logic (DEBUG)
  // =========================
  initializeScroll() {
    console.log("[CHAT] initializeScroll")

    const messages = this.element.querySelector(
      ".whatsapp-chat-messages"
    )
    console.log("[CHAT] messages container:", messages)

    if (!messages) return

    const separator = this.element.querySelector(
      ".whatsapp-new-messages-separator"
    )
    console.log("[CHAT] separator on init:", separator)

    const conversationId = this.element.dataset.conversationId
    const key = `scrolledToUnread:${conversationId}`

    console.log("[CHAT] scroll key:", key)

    if (separator && !sessionStorage.getItem(key)) {
      console.log("[CHAT] scrolling to separator")
      separator.scrollIntoView({
        behavior: "smooth",
        block: "center"
      })
      sessionStorage.setItem(key, "1")
      return
    }

    console.log("[CHAT] scrolling to bottom")
    messages.scrollTop = messages.scrollHeight
  }
}
