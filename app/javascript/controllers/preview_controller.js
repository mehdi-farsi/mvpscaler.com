import { Controller } from "@hotwired/stimulus"

// Controls desktop/mobile toggle and keeps the iframe areas sized to the viewport
export default class extends Controller {
    static targets = ["desktopWrap", "mobileWrap", "desktopBtn", "mobileBtn"]
    static values  = { headerOffset: Number }

    connect() {
        this.layout()
        window.addEventListener("resize", this.layout)
    }

    disconnect() {
        window.removeEventListener("resize", this.layout)
    }

    layout = () => {
        // Calculate available height (viewport minus fixed chrome)
        const header = document.querySelector("header.sticky")
        const headerH = header ? header.offsetHeight : 0
        const subnav  = document.getElementById("project-subnav")
        const subnavH = subnav ? subnav.offsetHeight : 0

        const availableH = window.innerHeight - headerH - subnavH
        this.element.style.setProperty("--preview-height", `${availableH}px`)

        // Ensure both wrappers get the same height (only one is visible)
        if (this.hasDesktopWrapTarget) this.desktopWrapTarget.style.height = `${availableH}px`
        if (this.hasMobileWrapTarget)  this.mobileWrapTarget.style.height  = `${availableH}px`
    }

    toDesktop() {
        this.desktopWrapTarget.classList.remove("hidden")
        this.mobileWrapTarget.classList.add("hidden")
        this.desktopBtnTarget.classList.add("bg-gray-900", "text-white")
        this.mobileBtnTarget.classList.remove("bg-gray-900", "text-white")
        this.layout()
    }

    toMobile() {
        this.mobileWrapTarget.classList.remove("hidden")
        this.desktopWrapTarget.classList.add("hidden")
        this.mobileBtnTarget.classList.add("bg-gray-900", "text-white")
        this.desktopBtnTarget.classList.remove("bg-gray-900", "text-white")
        this.layout()
    }
}
