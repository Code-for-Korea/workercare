import { Controller } from "@hotwired/stimulus"

// "쉬운 요약을 만드는 중" 프레임(turbo-frame#case_summary)을 일정 간격으로 다시 불러와 완성된 요약으로 바꾼다.
// ActionCable이 없어 폴링을 쓴다. 최대 timeout 값(기본 60초)까지만 기다리고, 넘기면 실패 문구를 보인다(점진적 향상: JS가 없으면
// 프레임 자체가 열리지 않는다).
// - 다시 불러오면 응답이 프레임 내용을 갈아 끼워 이 컨트롤러가 새로 connect된다. 그래서 시작 시각은 프레임 요소의
//   data-summary-poll-started-at에 둔다(컨트롤러 요소가 아니라).
// - disconnect와 turbo:before-cache에서 타이머를 지운다. before-cache에서는 시작 시각도 지워, 캐시에서 되돌아왔을 때 새로 센다.
export default class extends Controller {
  static targets = ["waiting", "timeout"]
  static values = { interval: { type: Number, default: 2500 }, timeout: { type: Number, default: 60000 } }

  connect() {
    this.frame = this.element.closest("turbo-frame")
    if (!this.frame) return

    this.beforeCacheHandler = () => this.leave()
    document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
    if (!this.frame.dataset.summaryPollStartedAt) this.frame.dataset.summaryPollStartedAt = String(Date.now())
    this.schedule()
  }

  disconnect() {
    this.stop()
    document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  schedule() {
    this.stop()
    if (this.elapsed() >= this.timeoutValue) return this.giveUp()

    this.timer = setTimeout(() => this.poll(), this.intervalValue)
  }

  poll() {
    this.timer = null
    if (!this.element.isConnected) return
    if (this.elapsed() >= this.timeoutValue) return this.giveUp()

    // 응답이 프레임을 바꾸면 이 요소는 떨어져 나가고 새 컨트롤러가 이어서 센다. 아직 붙어 있으면(요청 실패 등) 다시 예약한다.
    Promise.resolve(this.frame.reload())
      .catch(() => {})
      .then(() => { if (this.element.isConnected) this.schedule() })
  }

  giveUp() {
    if (this.hasWaitingTarget) this.waitingTarget.hidden = true
    if (this.hasTimeoutTarget) this.timeoutTarget.hidden = false
    this.element.setAttribute("aria-busy", "false")
  }

  leave() {
    this.stop()
    if (this.frame) delete this.frame.dataset.summaryPollStartedAt
  }

  stop() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = null
  }

  elapsed() {
    return Date.now() - Number(this.frame.dataset.summaryPollStartedAt || Date.now())
  }
}
