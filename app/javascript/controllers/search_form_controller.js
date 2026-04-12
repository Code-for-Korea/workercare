import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "button"]

  connect() {
    this.element.addEventListener("submit", this.showLoading.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("submit", this.showLoading.bind(this))
  }

  showLoading(event) {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("is-active")
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.buttonTarget.dataset.originalText = this.buttonTarget.value
      this.buttonTarget.value = this.buttonTarget.dataset.loadingText
    }
  }
}
