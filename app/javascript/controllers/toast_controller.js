import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bar"]
    static values  = { duration: Number }

    connect() {
        // Animate the bottom bar from 100% to 0%
        if (this.hasBarTarget) {
            // force layout, then set transition + shrink
            this.barTarget.style.width = "100%"
            this.barTarget.style.transition = `width ${this.duration}ms linear`
            requestAnimationFrame(() => { this.barTarget.style.width = "0%" })
        }

        // Fade-in (optional)
        this.element.classList.add("opacity-0", "translate-y-2")
        requestAnimationFrame(() => {
            this.element.classList.add("transition", "duration-200")
            this.element.classList.remove("opacity-0", "translate-y-2")
        })

        // Auto close
        this.timeout = setTimeout(() => this.close(), this.duration || 4000)
    }

    disconnect() {
        if (this.timeout) clearTimeout(this.timeout)
    }

    close() {
        // graceful fade-out then remove
        this.element.classList.add("opacity-0", "translate-y-2")
        this.element.classList.add("transition", "duration-200")
        setTimeout(() => this.element.remove(), 220)
    }
}
