import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    unread: Number
  }

  unreadValueChanged(value) {
    const baseTitle = "TransportApp"

    document.title =
      value > 0 ? `(${value}) ${baseTitle}` : baseTitle
  }
}
