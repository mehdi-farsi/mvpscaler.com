import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bar"]
    static values = { duration: Number }

    connect() {
        const dur = this.durationValue || 4000

        // Animate countdown bar
        requestAnimationFrame(() => {
            this.barTarget.style.transition = `width ${dur}ms linear`
            this.barTarget.style.width = "0%"
        })

        // Auto-dismiss after duration
        this.timeout = setTimeout(() => this.close(), dur)
    }

    disconnect() {
        clearTimeout(this.timeout)
    }

    close() {
        this.element.classList.add("opacity-0", "translate-x-3", "transition-all", "duration-300")
        setTimeout(() => this.element.remove(), 250)
    }
}