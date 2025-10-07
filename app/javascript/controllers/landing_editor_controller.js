import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["imageInput", "imagePreview", "fileInput"]
    static values = { urlMap: Object }

    updateImage(event) {
        const val = (event.currentTarget.value || "").trim()
        const url = this.resolveUrl(val)
        if (!url) return
        this.updatePreview(url, val)
    }

    pickFile() { this.fileInputTarget?.click() }

    fileChosen(event) {
        const file = event.currentTarget.files?.[0]
        if (!file) return
        const url = URL.createObjectURL(file)
        this.updatePreview(url, file.name)
    }

    updatePreview(url, alt) {
        // Scoped to the current field wrapper
        const wrapper = this.element.closest("[data-landing-editor-field]") || this.element
        const preview = wrapper.querySelector("[data-landing-editor-target='imagePreview']") || this.imagePreviewTarget
        if (preview) {
            preview.src = url
            preview.alt = alt || "image preview"
        }
    }

    resolveUrl(v) {
        if (!v) return null
        if (/^https?:\/\//i.test(v) || v.startsWith("/")) return v
        if (this.hasUrlMapValue && this.urlMapValue[v]) return this.urlMapValue[v]
        return `/assets/${v}`
    }
}
