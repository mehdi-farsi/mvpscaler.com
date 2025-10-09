// app/javascript/controllers/preview_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["desktopWrap", "mobileWrap", "desktopBtn", "mobileBtn"]

    connect() {
        // Start in desktop mode, set colors
        this.toDesktop()
    }

    toDesktop() {
        this.desktopWrapTarget.classList.remove("hidden")
        this.mobileWrapTarget.classList.add("hidden")
        this.setActive(this.desktopBtnTarget, true)
        this.setActive(this.mobileBtnTarget, false)
    }

    toMobile() {
        this.desktopWrapTarget.classList.add("hidden")
        this.mobileWrapTarget.classList.remove("hidden")
        this.setActive(this.desktopBtnTarget, false)
        this.setActive(this.mobileBtnTarget, true)
    }

    setActive(element, isActive) {
        element.setAttribute("aria-pressed", isActive ? "true" : "false")

        // Add green color for active, neutral for inactive
        element.classList.toggle("text-emerald-500", isActive)
        element.classList.toggle("hover:text-emerald-400", isActive)
        element.classList.toggle("text-gray-500", !isActive)
        element.classList.toggle("hover:text-gray-300", !isActive)
    }
}