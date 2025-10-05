import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hex"]

    connect() {
        this.picker = document.getElementById(this.element.dataset.colorSyncPickerId)
        if (!this.picker || !this.hasHexTarget) return
        if (!this.hexTarget.value && this.picker.value) this.hexTarget.value = this.picker.value
        this.onPicker = e => this.hexTarget.value = e.target.value
        this.onHex = e => {
            const v = e.target.value
            if (/^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(v)) this.picker.value = v
        }
        this.picker.addEventListener("input", this.onPicker)
        this.hexTarget.addEventListener("input", this.onHex)
    }

    disconnect() {
        if (this.picker) this.picker.removeEventListener("input", this.onPicker)
        if (this.hasHexTarget) this.hexTarget.removeEventListener("input", this.onHex)
    }
}