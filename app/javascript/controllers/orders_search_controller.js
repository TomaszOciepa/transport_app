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
    const terms = query.split(/\s+/) // ["listopad", "wgm97102"]
  
    this.rows.forEach(row => {
      const text = row.innerText.toLowerCase()
      let months = row.dataset.searchMonths || ""
  
      Object.keys(this.monthMap).forEach(en => {
        if (months.includes(en)) {
          months += " " + this.monthMap[en]
        }
      })
  
      const searchable = text + " " + months
  
      // 🔥 KLUCZOWA ZMIANA
      const matchesAll = terms.every(term => searchable.includes(term))
  
      row.style.display = matchesAll ? "" : "none"
    })
  }
  
}
