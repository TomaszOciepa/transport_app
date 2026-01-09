import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "chevron"]

  connect() {
    // start: zwinięte
    this.isOpen = false
  }

  toggle() {
    this.isOpen = !this.isOpen

    this.contentTarget.classList.toggle("is-open", this.isOpen)
    this.chevronTarget.classList.toggle("is-open", this.isOpen)
  }
}
