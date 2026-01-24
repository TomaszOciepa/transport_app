import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.input = document.getElementById("whatsapp_file_input")
    this.preview = document.getElementById("whatsapp-file-preview")
    this.name = document.getElementById("whatsapp-file-name")
    this.removeBtn = document.getElementById("whatsapp-file-remove")

    if (!this.input) return

    this.input.addEventListener("change", () => {
      if (this.input.files.length > 0) {
        this.name.textContent = this.input.files[0].name
        this.preview.hidden = false
      }
    })

    this.removeBtn.addEventListener("click", () => {
      this.input.value = ""
      this.preview.hidden = true
    })
  }
}
