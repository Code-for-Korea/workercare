import { Controller } from "@hotwired/stimulus"

// 폼을 보내는 동안 로딩 오버레이를 보이고 버튼을 잠근다(점진적 향상: JS가 없어도 폼은 그대로 동작한다).
// 오버레이 마크업은 app/views/shared/_loading_overlay.html.erb.
// - `submit` 이벤트는 브라우저 검증을 통과한 뒤에만 발생하므로 취소된 제출에는 뜨지 않는다.
//   Turbo Drive도 같은 `submit`을 받아 fetch로 보내므로 Turbo 유무와 무관하게 이것 하나로 충분하다.
// - 뒤로 가기(Turbo 캐시, bfcache)로 돌아왔을 때 멈춘 스피너가 남지 않게 되돌린다.
export default class extends Controller {
  static targets = ["overlay", "button"]

  connect() {
    this.submitHandler = this.showLoading.bind(this)
    this.resetHandler = this.reset.bind(this)
    this.pageShowHandler = (event) => { if (event.persisted) this.reset() }
    this.element.addEventListener("submit", this.submitHandler)
    document.addEventListener("turbo:before-cache", this.resetHandler)
    window.addEventListener("pageshow", this.pageShowHandler)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.submitHandler)
    document.removeEventListener("turbo:before-cache", this.resetHandler)
    window.removeEventListener("pageshow", this.pageShowHandler)
  }

  showLoading(event) {
    if (event.defaultPrevented) return

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("is-active")
      this.overlayTarget.setAttribute("aria-hidden", "false")
    }
    if (this.hasButtonTarget && !this.buttonTarget.disabled) {
      const button = this.buttonTarget
      const loadingText = button.dataset.loadingText
      this.originalText = this.buttonText(button)
      button.disabled = true
      if (loadingText) this.setButtonText(button, loadingText)
    }
  }

  reset() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("is-active")
      this.overlayTarget.setAttribute("aria-hidden", "true")
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      if (this.originalText !== undefined) this.setButtonText(this.buttonTarget, this.originalText)
    }
    this.originalText = undefined
  }

  // input[type=submit]은 value, <button>은 textContent
  buttonText(button) {
    return button.tagName === "INPUT" ? button.value : button.textContent
  }

  setButtonText(button, text) {
    if (button.tagName === "INPUT") {
      button.value = text
    } else {
      button.textContent = text
    }
  }
}
