// app/javascript/controllers/landing_editor_controller.js
import { Controller } from "@hotwired/stimulus"

// Controls image-asset inputs with a live preview.
// Works with either a <select> of known assets or a free-text <input>.
// Provide a JSON filename->URL map via data-url-map-value when you have fingerprinted assets.
export default class extends Controller {
    static targets = ["imageInput", "imagePreview"]
    static values = {
        urlMap: Object // { "hero-bg.webp": "/assets/hero-bg-xxxxx.webp", ... }
    }

    // Hook up to both `input` and `change` events
    updateImage(event) {
        const el = event.currentTarget
        const val = (el.value || "").trim()
        const url = this.resolveUrl(val)

        if (!url) return

        // Find the preview that belongs to this input (same wrapper)
        let preview = el.closest("[data-landing-editor-target-wrapper]")
            ?.querySelector("[data-landing-editor-target='imagePreview']")

        // Fallback: use first previewTarget
        if (!preview && this.hasImagePreviewTarget) preview = this.imagePreviewTargets[0]

        if (preview) {
            preview.src = url
            preview.alt = val || "image preview"
        }
    }

    resolveUrl(filenameOrUrl) {
        if (!filenameOrUrl) return null

        // If full URL or absolute path, use as-is
        if (/^https?:\/\//i.test(filenameOrUrl) || filenameOrUrl.startsWith("/")) {
            return filenameOrUrl
        }

        // If we have a urlMap (fingerprinted assets), prefer it
        if (this.hasUrlMapValue && this.urlMapValue[filenameOrUrl]) {
            return this.urlMapValue[filenameOrUrl]
        }

        // Heuristic fallback: try Rails /assets path (non-fingerprinted or dev)
        return `/assets/${filenameOrUrl}`
    }
}
