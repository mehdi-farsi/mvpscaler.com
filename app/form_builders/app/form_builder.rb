# app/form_builders/app/form_builder.rb
# frozen_string_literal: true
module App
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Public API (unchanged)
    def text_field_row(method, **opts)      = input_row(method, :text_field,  **opts)
    def email_field_row(method, **opts)     = input_row(method, :email_field, **opts)
    def url_field_row(method, **opts)       = input_row(method, :url_field,   **opts)
    def number_field_row(method, **opts)    = input_row(method, :number_field, **opts)
    def password_field_row(method, reveal: false, **opts)
      input_row(method, :password_field, reveal:, **opts)
    end
    def text_area_row(method, **opts)       = input_row(method, :text_area, **opts)
    def select_row(method, choices, **opts) = input_row(method, :select, choices, **opts)
    def color_field_row(method, **opts)     = color_row(method, **opts)
    def toggle_row(method, label: nil, hint: nil, **opts)
      switch_row(method, label:, hint:, **opts)
    end

    # Image asset (kept, but compact)
    def image_asset_row(method = nil, preview_url:, choices: [], input_name:, upload_name:, label: nil, hint: nil)
      label_text = label || (method ? method.to_s.humanize : "Image")
      url_map = Array(choices).index_with { |fn| @template.image_path(fn) } rescue {}
      preview = preview_url.to_s

      body = @template.content_tag(:div,
                                   class: "grid grid-cols-[160px_1fr] items-start gap-4",
                                   data: { controller: "landing-editor", "landing-editor-url-map-value": url_map.to_json }
      ) do
        left  = @template.content_tag(:label, label_text, class: "text-[13px] font-medium text-gray-700 mt-2")
        right = @template.content_tag(:div, class: "flex items-center gap-4") do
          thumb = @template.content_tag(:div, class: "w-28 h-16 overflow-hidden rounded-md bg-gray-100 ring-1 ring-gray-200") do
            @template.image_tag(preview, alt: "", class: "w-full h-full object-cover",
                                data: { "landing-editor-target": "imagePreview" },
                                onerror: "this.src=''; this.classList.add('opacity-40')"
            )
          end

          selector =
            if choices.present?
              @template.select_tag(
                input_name,
                @template.options_for_select([["None",""]] + choices.map { |c| [c,c] }, preview_url.presence),
                class: compact_input_classes,
                data: { "landing-editor-target": "imageInput" },
                onchange: "this.dispatchEvent(new Event('input'))"
              )
            else
              @template.text_field_tag(
                input_name, preview_url,
                placeholder: "hero-bg.webp or URL",
                class: compact_input_classes,
                data: { "landing-editor-target": "imageInput", action: "input->landing-editor#updateImage change->landing-editor#updateImage" }
              )
            end

          upload = @template.content_tag(:div, class: "flex items-center gap-2") do
            @template.button_tag(type: "button",
                                 class: "text-[13px] px-3 h-8 inline-flex items-center gap-2 rounded-md ring-1 ring-gray-300 hover:bg-gray-50",
                                 data: { action: "landing-editor#pickFile" }
            ) { @template.content_tag(:i, "", class: "bi bi-upload") + " Upload" } +
              @template.file_field_tag(upload_name, accept: "image/*", class: "hidden",
                                       data: { "landing-editor-target": "fileInput", action: "change->landing-editor#fileChosen" })
          end

          @template.safe_join([thumb, selector, upload])
        end

        @template.safe_join([left, right])
      end

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1 ml-[160px]") : nil
      @template.safe_join([body, hint_el].compact)
    end

    def submit_primary(text, **opts)   = submit_btn(text, :primary, **opts)
    def submit_secondary(text, **opts) = submit_btn(text, :secondary, **opts)
    def submit_danger(text, **opts)    = submit_btn(text, :danger, **opts)

    private

    # ——— Compact field (label left, control right), no big shadows ———
    def input_row(method, input_helper, *args, label: nil, hint: nil, icon: nil, reveal: false, **opts)
      has_error  = object.respond_to?(:errors) && object.errors[method].present?
      label_text = label || method.to_s.humanize

      input_opts = {
        class: [opts.delete(:class), compact_input_classes(has_error:)].compact.join(" "),
        aria: {
          invalid: has_error ? "true" : "false",
          describedby: has_error ? error_id(method) : nil
        }.compact
      }

      field =
        if input_helper == :select
          select(method, *args, **input_opts)
        elsif input_helper == :text_area
          # compact textarea: same height rhythm, no giant box
          text_area(method, **input_opts.merge(rows: (opts[:rows] || 3), class: [input_opts[:class], "min-h-[88px]"].join(" ")))
        else
          public_send(input_helper, method, **input_opts.merge(args[0] || {}))
        end

      left  = @template.content_tag(:label, label_text, class: "text-[13px] font-medium text-gray-700 mt-2")
      right = @template.content_tag(:div, class: "relative") { field }

      row = @template.content_tag(:div, class: "grid grid-cols-[160px_1fr] items-start gap-4") do
        @template.safe_join([left, right])
      end

      hint_el  = hint.present? ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1 ml-[160px]") : nil
      error_el = has_error ? @template.content_tag(:p, object.errors.full_messages_for(method).first, id: error_id(method), class: "text-xs text-red-600 mt-1 ml-[160px]") : nil

      @template.safe_join([row, hint_el, error_el].compact)
    end

    def color_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      value      = object.try(method).presence || opts[:value]

      left = @template.content_tag(:label, label_text, class: "text-[13px] font-medium text-gray-700 mt-2")

      chip = @template.tag.input(
        type: "color",
        value: (value || "#ffffff"),
        class: "h-8 w-10 cursor-pointer rounded border border-gray-300"
      )

      text = text_field(method,
                        class: compact_input_classes,
                        placeholder: "#RRGGBB",
                        value: value
      )

      right = @template.content_tag(:div, class: "flex items-center gap-3") { chip + text }

      row = @template.content_tag(:div, class: "grid grid-cols-[160px_1fr] items-center gap-4") do
        @template.safe_join([left, right])
      end

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1 ml-[160px]") : nil
      @template.safe_join([row, hint_el].compact)
    end

    def switch_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      left  = @template.content_tag(:span, label_text, class: "text-[13px] font-medium text-gray-700 mt-2")
      input = check_box(method, **opts.merge(class: "peer sr-only"))
      slider = @template.content_tag(:span, "", class: "h-5 w-10 rounded-full bg-gray-300 ring-1 ring-inset ring-gray-200 relative transition
                           after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:shadow after:transition
                           peer-checked:bg-emerald-600 peer-checked:after:translate-x-5")
      right = @template.content_tag(:label, input + slider, class: "inline-flex items-center cursor-pointer")

      row = @template.content_tag(:div, class: "grid grid-cols-[160px_1fr] items-center gap-4") do
        @template.safe_join([left, right])
      end

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1 ml-[160px]") : nil
      @template.safe_join([row, hint_el].compact)
    end

    def submit_btn(text, style, **opts)
      base =
        case style
        when :primary
          "inline-flex items-center gap-2 rounded-md bg-emerald-600 px-4 h-9 text-[13px] font-semibold text-white hover:bg-emerald-500"
        when :secondary
          "inline-flex items-center gap-2 rounded-md ring-1 ring-gray-300 bg-white px-4 h-9 text-[13px] text-gray-800 hover:bg-gray-50"
        when :danger
          "inline-flex items-center gap-2 rounded-md bg-red-600 px-4 h-9 text-[13px] font-semibold text-white hover:bg-red-500"
        end
      submit(text, { class: base, data: { turbo: true } }.merge(opts))
    end

    # ——— helpers ———
    def compact_input_classes(has_error: false)
      [
        "h-9 text-[13px] px-3 rounded-md",
        "ring-1 ring-inset",
        (has_error ? "ring-red-400 focus:ring-red-500" : "ring-gray-300 focus:ring-emerald-500"),
        "bg-white text-gray-900 placeholder-gray-400",
        "focus:outline-none transition"
      ].join(" ")
    end

    def error_id(method) = "#{object_name}_#{method}_error"
  end
end
