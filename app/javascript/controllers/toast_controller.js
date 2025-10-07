import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bar"]
    static values  = { duration: Number }

    connect() {
        // start the countdown bar animation
        const dur = this.durationValue || 4000
        // force a reflow so transition applies
        requestAnimationFrame(() => {
            this.barTarget.style.transition = `width ${dur}ms linear`
            this.barTarget.style.width = "0%"
        })
        // schedule auto close
        this.timeout = setTimeout(() => this.close(), dur)
    }

    disconnect() {
        clearTimeout(this.timeout)
    }

    close() {
        this.element.classList.add("opacity-0", "translate-x-3", "transition-all", "duration-200")
        setTimeout(() => this.element.remove(), 180)
    }
}
