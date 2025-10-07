import { Controller } from "@hotwired/stimulus"

// Reusable toast-style notifications with countdown
export default class extends Controller {
    static targets = ["toast"]
    connect() {
        this.element.addEventListener("notify", (event) => {
            const { message, type = "success", duration = 4000 } = event.detail
            this.show(message, type, duration)
        })

        // Initialize any SSR-rendered flashes
        this.toastTargets.forEach((t) => {
            const message = t.dataset.message
            const type = t.dataset.type || "success"
            this.show(message, type)
            t.remove()
        })
    }

    show(message, type = "success", duration = 4000) {
        const toast = document.createElement("div")
        toast.className = `
      pointer-events-auto relative flex items-center justify-between w-80
      rounded-lg shadow-lg overflow-hidden text-sm text-white
      px-4 py-3 bg-${type === "error" ? "red" : type === "info" ? "blue" : "emerald"}-600
      animate-fade-in
    `
        toast.innerHTML = `
      <span class="font-medium">${message}</span>
      <button class="ml-3 opacity-70 hover:opacity-100 transition" data-action="click->notifications#close">✕</button>
      <div class="absolute bottom-0 left-0 h-0.5 bg-white/70"
           style="width: 100%; transition: width ${duration}ms linear;"></div>
    `
        this.element.appendChild(toast)

        // trigger countdown animation
        requestAnimationFrame(() => {
            const bar = toast.querySelector("div.absolute")
            bar.style.width = "0%"
        })

        // remove after duration
        setTimeout(() => this.fadeOut(toast), duration)
    }

    close(event) {
        const toast = event.target.closest("div")
        this.fadeOut(toast)
    }

    fadeOut(toast) {
        if (!toast) return
        toast.classList.add("opacity-0", "translate-x-5", "transition-all", "duration-300")
        setTimeout(() => toast.remove(), 300)
    }
}
