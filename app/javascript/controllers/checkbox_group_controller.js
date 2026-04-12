import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  selectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = true
    })
  }

  deselectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
  }
}
