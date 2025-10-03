import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggle(event) {
        event.preventDefault()
        const input = this.element.querySelector("input[type='password'], input[type='text']")
        if (!input) return
        input.type = input.type === "password" ? "text" : "password"
        const icon = event.currentTarget.querySelector("i")
        if (icon) {
            icon.classList.toggle("bi-eye")
            icon.classList.toggle("bi-eye-slash")
        }
    }
}