import { Controller } from "@hotwired/stimulus"
import gsap from "gsap"

// Controls the main dashboard sidebar (expand on hover, collapse on leave)
export default class extends Controller {
    static targets = ["label", "backdrop"]
    static values = {
        collapsedWidth: Number,
        expandedWidth: Number,
        animationDuration: Number,
        ease: String
    }

    connect() {
        this.isExpanded = false
        this.panel = this.element
        this.duration = this.animationDurationValue || 0.22
        this.ease = this.easeValue || "power2.out"

        // Initial collapsed state
        this._setWidth(this.collapsedWidthValue || 64)
        gsap.set(this.labelTargets, { opacity: 0, pointerEvents: "none" })
    }

    expand() {
        if (this.isExpanded) return
        this.isExpanded = true

        gsap.to(this.panel, {
            width: this.expandedWidthValue || 240,
            duration: this.duration,
            ease: this.ease
        })

        gsap.to(this.labelTargets, {
            opacity: 1,
            pointerEvents: "auto",
            stagger: 0.01,
            delay: 0.02,
            duration: this.duration * 0.9,
            ease: this.ease
        })

        if (this.hasBackdropTarget) {
            this.backdropTarget.classList.remove("hidden")
        }
    }

    collapse() {
        if (!this.isExpanded) return
        this.isExpanded = false

        gsap.to(this.labelTargets, {
            opacity: 0,
            pointerEvents: "none",
            duration: this.duration * 0.6,
            ease: "power1.out"
        })

        gsap.to(this.panel, {
            width: this.collapsedWidthValue || 64,
            duration: this.duration,
            ease: this.ease,
            onComplete: () => {
                if (this.hasBackdropTarget) {
                    this.backdropTarget.classList.add("hidden")
                }
            }
        })
    }

    _setWidth(px) {
        this.panel.style.width = `${px}px`
    }
}
