import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

export default class extends Controller {
    static targets = ["hero", "cards"]

    connect() {
        // Wait for paint, then animate
        requestAnimationFrame(() => {
            gsap.from(this.heroTarget, {
                y: 20,
                opacity: 0,
                duration: 0.6,
                ease: "power2.out"
            })

            if (this.hasCardsTarget) {
                gsap.from(this.cardsTarget.children, {
                    y: 24,
                    opacity: 0,
                    duration: 0.5,
                    ease: "power2.out",
                    stagger: 0.1,
                    delay: 0.15
                })
            }
        })
    }
}
