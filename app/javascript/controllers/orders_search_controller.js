import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "rows"]

  connect() {
    this.rows = Array.from(this.rowsTarget.querySelectorAll("tr"))

    this.monthMap = {
      "january": "styczeń sty 01",
      "february": "luty lut 02",
      "march": "marzec mar 03",
      "april": "kwiecień kwi 04",
      "may": "maj 05",
      "june": "czerwiec cze 06",
      "july": "lipiec lip 07",
      "august": "sierpień sie 08",
      "september": "wrzesień wrz 09",
      "october": "październik paź 10",
      "november": "listopad lis 11",
      "december": "grudzień gru 12"
    }
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    const tokens = query.split(/\s+/)   // ["06", "lis", "wgm97105"]
  
    const rows = Array.from(this.rowsTarget.querySelectorAll("tr"))
  
    let currentSeparator = null
    let visibleUnderSeparator = false
  
    rows.forEach(row => {
      // Separator dnia
      if (row.classList.contains("day-separator-row")) {
        if (currentSeparator) {
          currentSeparator.style.display = visibleUnderSeparator ? "" : "none"
        }
  
        currentSeparator = row
        visibleUnderSeparator = false
        return
      }
  
      const text = row.innerText.toLowerCase()
  
      // każdy token musi pasować
      const match = tokens.every(token => text.includes(token))
  
      row.style.display = match ? "" : "none"
  
      if (match) visibleUnderSeparator = true
    })
  
    if (currentSeparator) {
      currentSeparator.style.display = visibleUnderSeparator ? "" : "none"
    }
  }
  
  
  
}
