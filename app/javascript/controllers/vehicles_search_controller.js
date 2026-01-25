import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "rows"]

  connect() {
    this.rows = Array.from(this.rowsTarget.querySelectorAll("tr"))
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    const terms = query.split(/\s+/)

    this.rows.forEach(row => {
      const text = row.innerText.toLowerCase()
      const matchesAll = terms.every(term => text.includes(term))
      row.style.display = matchesAll ? "" : "none"
    })
  }
}
