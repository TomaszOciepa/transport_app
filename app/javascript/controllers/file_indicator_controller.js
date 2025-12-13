import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "preview"];

  fileSelected(event) {
    const file = event.target.files[0];
    if (!file) return;

    // zmiana ikony ➕ → 📎
    this.buttonTarget.innerHTML = `<i class="bi bi-paperclip"></i>`;
    this.buttonTarget.classList.add("file-selected");

    // pokazanie nazwy pliku
    this.previewTarget.textContent = `📎 ${file.name}`;
    this.previewTarget.classList.remove("d-none");
  }
}
