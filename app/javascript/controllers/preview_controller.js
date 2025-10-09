import { Controller } from "@hotwired/stimulus"

// Controls desktop/mobile toggle + responsive heights
export default class extends Controller {
    static targets = ["desktopWrap", "mobileWrap", "desktopBtn", "mobileBtn", "phoneFrame"]
    static values  = { headerOffset: Number }

    connect() {
        // start in desktop mode with correct icon state
        this.toDesktop()
        this.layout()
        this._onResize = () => this.layout()
        window.addEventListener("resize", this._onResize, { passive: true })
    }

    disconnect() {
        window.removeEventListener("resize", this._onResize)
    }

    layout() {
        // Calculate available height (viewport minus fixed chrome)
        const header = document.querySelector("header.sticky")
        const headerH = header ? header.offsetHeight : 0
        const subnav  = document.getElementById("project-subnav")
        const subnavH = subnav ? subnav.offsetHeight : 0

        const availableH = window.innerHeight - headerH - subnavH
        this.element.style.setProperty("--preview-height", `${availableH}px`)

        if (this.hasDesktopWrapTarget) this.desktopWrapTarget.style.height = `${availableH}px`
        if (this.hasMobileWrapTarget)  this.mobileWrapTarget.style.height  = `${availableH}px`

        // Phone viewport sizing: keep a nice max, center in its frame
        if (this.hasPhoneFrameTarget) {
            // 44px top+bottom padding box in your markup -> leave ~64px breathing room
            const maxH = Math.max(520, Math.min(availableH - 64, 820)) // clamp between 520..820
            this.phoneFrameTarget.style.height = `${maxH}px`
            // keep a common "device" width (iPhone 14-ish)
            this.phoneFrameTarget.style.width  = `393px`
        }
    }

    toDesktop() {
        this.desktopWrapTarget.classList.remove("hidden")
        this.mobileWrapTarget.classList.add("hidden")
        this._setActive(this.desktopBtnTarget, true)
        this._setActive(this.mobileBtnTarget, false)
        this.layout()
    }

    toMobile() {
        this.mobileWrapTarget.classList.remove("hidden")
        this.desktopWrapTarget.classList.add("hidden")
        this._setActive(this.desktopBtnTarget, false)
        this._setActive(this.mobileBtnTarget, true)
        this.layout()
    }

    _setActive(el, active) {
        el.setAttribute("aria-pressed", active ? "true" : "false")
        // icon color only
        el.classList.toggle("text-emerald-500", active)
        el.classList.toggle("hover:text-emerald-400", active)
        el.classList.toggle("text-gray-500", !active)
        el.classList.toggle("hover:text-gray-300", !active)
    }
}