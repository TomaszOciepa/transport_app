import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "item"]

  filter() {
    const query = this.searchTarget.value.toLowerCase().trim()

    this.itemTargets.forEach(item => {
      const text = item.dataset.searchText
      item.hidden = !text.includes(query)
    })
  }
}
