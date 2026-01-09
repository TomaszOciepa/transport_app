import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "search", "list", "item"]

  connect() {
    this.handleOutsideClick = this.outsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)

    // 🔔 zamknij menu po wyborze kierowcy
    this.handleDriverSelected = this.close.bind(this)
    window.addEventListener("driver:selected", this.handleDriverSelected)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    window.removeEventListener("driver:selected", this.handleDriverSelected)
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
}
