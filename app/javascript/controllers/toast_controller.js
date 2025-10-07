import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bar"]
    static values  = { duration: Number }

    connect() {
        const dur = this.durationValue || 4000

        // Animate the countdown bar
        if (this.hasBarTarget) {
            const bar = this.barTarget

            // Set initial state without transition
            bar.style.transition = "none"
            bar.style.width = "100%"

            // Force layout, then enable transition and shrink
            // (without this, some browsers won't animate width)
            // eslint-disable-next-line no-unused-expressions
            bar.offsetWidth
            bar.style.transition = `width ${dur}ms linear`

            requestAnimationFrame(() => {
                bar.style.width = "0%"
            })
        }

        // Fade-in
        this.element.classList.add("opacity-0", "translate-y-2")
        requestAnimationFrame(() => {
            this.element.classList.add("transition", "duration-200")
            this.element.classList.remove("opacity-0", "translate-y-2")
        })

        // Auto close
        this.timeout = setTimeout(() => this.close(), dur)
    }

    disconnect() {
        if (this.timeout) clearTimeout(this.timeout)
    }

    close() {
        this.element.classList.add("opacity-0", "translate-y-2", "transition", "duration-200")
        setTimeout(() => {
            this.element.remove()
        }, 220)
    }
}