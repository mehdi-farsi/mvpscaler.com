# frozen_string_literal: true
module App
  class FormBuilder < ActionView::Helpers::FormBuilder
    # ─────────────────────────────────────────────────────────────────────────────
    # Public API
    # ─────────────────────────────────────────────────────────────────────────────
    # Basic rows
    def text_field_row(method, **opts)     = input_row(method, :text_field,  **opts)
    def email_field_row(method, **opts)    = input_row(method, :email_field, **opts)
    def url_field_row(method, **opts)      = input_row(method, :url_field,   **opts)
    def number_field_row(method, **opts)   = input_row(method, :number_field, **opts)
    def password_field_row(method, reveal: false, **opts)
      input_row(method, :password_field, reveal:, **opts)
    end
    def text_area_row(method, **opts)      = input_row(method, :text_area, **opts) # (aka "longtext")
    def select_row(method, choices, **opts)= input_row(method, :select, choices, **opts)
    def color_field_row(method, **opts)    = color_row(method, **opts)
    def toggle_row(method, label: nil, hint: nil, **opts)
      switch_row(method, label:, hint:, **opts)
    end

    # “image_asset” row: preview + select/text + upload
    #
    # Options:
    #   preview_url: String (shown in the thumbnail)
    #   choices:     Array[String] (filenames) OR leave empty to get a text input
    #   input_name:  Custom name attribute (e.g. "settings_flat[general.background_image]")
    #   upload_name: Custom name for <input type="file"> (e.g. "uploads[general.background_image]")
    #   label:       Label text
    #   hint:        Small hint text under the control
    def image_asset_row(method = nil, preview_url:, choices: [], input_name:, upload_name:, label: nil, hint: nil)
      label_text = label || (method ? method.to_s.humanize : "Image")

      url_map = Array(choices).index_with { |fn| @template.image_path(fn) } rescue {}
      preview = preview_url.to_s

      control =
        @template.content_tag(:div,
                              class: "flex flex-col gap-2",
                              data: {
                                controller: "landing-editor",
                                "landing-editor-url-map-value": url_map.to_json
                              }
        ) do
          input =
            if choices.present?
              @template.select_tag(input_name,
                                   @template.options_for_select([["", ""]] + choices.map { |c| [c, c] }),
                                   class: "rounded-lg border border-gray-300 bg-white/80 px-3 py-2 text-gray-900 shadow-sm hover:border-emerald-400 focus:ring-4 focus:ring-emerald-500/20 transition-all",
                                   data: { "landing-editor-target": "imageInput" },
                                   onchange: "this.dispatchEvent(new Event('input'))"
              )
            else
              @template.text_field_tag(input_name, preview_url,
                                       placeholder: "e.g. hero-bg.webp or URL",
                                       class: "rounded-lg border border-gray-300 bg-white/80 px-3 py-2 text-gray-900 shadow-sm hover:border-emerald-400 focus:ring-4 focus:ring-emerald-500/20 transition-all",
                                       data: { "landing-editor-target": "imageInput", action: "input->landing-editor#updateImage change->landing-editor#updateImage" }
              )
            end

          upload_button =
            @template.content_tag(:div, class: "flex items-center gap-3") do
              @template.button_tag(type: "button",
                                   class: "inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-3 py-1.5 text-sm text-gray-700 hover:bg-emerald-50 hover:text-emerald-700 transition-all",
                                   data: { action: "landing-editor#pickFile" }
              ) do
                @template.content_tag(:i, "", class: "bi bi-upload") + " Upload"
              end +
                @template.file_field_tag(upload_name,
                                         accept: "image/*",
                                         class: "hidden",
                                         data: { "landing-editor-target": "fileInput", action: "change->landing-editor#fileChosen" }
                )
            end

          thumbnail =
            @template.content_tag(:div, class: "relative flex items-center gap-4 p-3 rounded-xl border border-gray-200 bg-gray-50 hover:border-emerald-400 transition-all") do
              @template.content_tag(:div, class: "w-28 h-20 rounded-lg overflow-hidden bg-gray-100 shadow-inner border border-gray-200 shrink-0") do
                @template.image_tag(preview,
                                    alt: (preview.present? ? "image preview" : "no image"),
                                    class: "w-full h-full object-cover transition-all hover:scale-105",
                                    data: { "landing-editor-target": "imagePreview" },
                                    onerror: "this.src=''; this.alt='no image'; this.classList.add('opacity-40')"
                )
              end +
                @template.content_tag(:div, class: "flex flex-col flex-1 gap-2") do
                  input + upload_button
                end
            end

          @template.content_tag(:label, label_text, class: "text-sm font-medium text-gray-700") +
            thumbnail
        end

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil
      @template.content_tag(:div, class: "space-y-1") { @template.safe_join([control, hint_el].compact) }
    end

    # Buttons
    def submit_primary(text, **opts)   = submit_btn(text, :primary, **opts)
    def submit_secondary(text, **opts) = submit_btn(text, :secondary, **opts)
    def submit_danger(text, **opts)    = submit_btn(text, :danger, **opts)

    # ─────────────────────────────────────────────────────────────────────────────
    # Internals
    # ─────────────────────────────────────────────────────────────────────────────
    private

    # Generic labeled input row (floating label)
    def input_row(method, input_helper, *args, label: nil, hint: nil, icon: nil, reveal: false, **opts)
      has_error  = object.respond_to?(:errors) && object.errors[method].present?
      label_text = label || method.to_s.humanize

      input_classes = %w[
        peer w-full rounded-xl border border-gray-300 bg-white px-3.5 pt-5 pb-2
        text-gray-900 placeholder-transparent
        focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/20
        transition
      ]
      input_classes << "pl-10" if icon
      input_classes << "border-red-500 focus:ring-red-500/20" if has_error

      input_opts = {
        class: [opts.delete(:class), input_classes.join(" ")].compact.join(" "),
        aria: {
          invalid: has_error ? "true" : "false",
          describedby: has_error ? error_id(method) : nil
        }.compact
      }

      field =
        if input_helper == :select
          select(method, *args, **input_opts)
        elsif input_helper == :text_area
          text_area(method, **input_opts.merge(rows: (opts[:rows] || 4)))
        else
          public_send(input_helper, method, **input_opts.merge(args[0] || {}))
        end

      left_icon =
        if icon
          @template.content_tag(:span,
                                @template.content_tag(:i, "", class: "bi bi-#{icon}"),
                                class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400"
          )
        end

      right_btn =
        if reveal
          @template.content_tag(:button, type: "button",
                                class: "absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600",
                                data: { controller: "reveal", action: "reveal#toggle" }
          ) { @template.content_tag(:i, "", class: "bi bi-eye") }
        end

      float_label = @template.content_tag(:label, label_text,
                                          class: "absolute left-3.5 top-2 text-sm text-gray-500 transition-all
                peer-placeholder-shown:top-3.5 peer-placeholder-shown:text-base peer-placeholder-shown:text-gray-400
                peer-focus:top-2 peer-focus:text-sm peer-focus:text-emerald-600"
      )

      field_with_chrome = @template.content_tag(:div, class: "relative") do
        @template.safe_join([left_icon, field, right_btn, float_label].compact)
      end

      hint_el  = hint.present? ? @template.content_tag(:p, hint, class: "mt-1 text-xs text-gray-500") : nil
      error_el = error_text(method)

      @template.content_tag(:div, class: "space-y-1") do
        @template.safe_join([field_with_chrome, hint_el, error_el].compact)
      end
    end

    # Color row (color chip + hex text)
    def color_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      value      = object.try(method).presence || opts[:value]

      color_chip = @template.tag.input(
        type: "color",
        value: (value || "#ffffff"),
        class: "h-9 w-12 cursor-pointer rounded-lg border border-gray-200 shadow-sm hover:ring-2 hover:ring-emerald-300 transition"
      )

      text = text_field(method,
                        class: "peer w-full rounded-xl border border-gray-300 bg-white px-3.5 pt-5 pb-2 text-gray-900 placeholder-transparent focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/20 transition",
                        placeholder: "#RRGGBB",
                        value: value
      )

      float_label = @template.content_tag(:label, label_text,
                                          class: "absolute left-3.5 top-2 text-sm text-gray-500 transition-all
                peer-placeholder-shown:top-3.5 peer-placeholder-shown:text-base peer-placeholder-shown:text-gray-400
                peer-focus:top-2 peer-focus:text-sm peer-focus:text-emerald-600"
      )

      row =
        @template.content_tag(:div, class: "flex items-center gap-3") do
          color_chip +
            @template.content_tag(:div, class: "relative flex-1") do
              @template.safe_join([text, float_label])
            end
        end

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil
      @template.content_tag(:div, class: "space-y-1") { @template.safe_join([row, hint_el].compact) }
    end

    # Toggle (checkbox styled as switch)
    def switch_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      box = @template.content_tag(:label, class: "inline-flex items-center gap-3 cursor-pointer") do
        input = check_box(method, **opts.merge(class: "peer sr-only"))
        slider = @template.content_tag(:span, "",
                                       class: "h-5 w-10 rounded-full bg-gray-300 ring-1 ring-inset ring-gray-200 relative transition
                  after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:shadow after:transition
                  peer-checked:bg-emerald-600 peer-checked:after:translate-x-5"
        )
        input + slider + @template.content_tag(:span, label_text, class: "text-sm text-gray-800")
      end
      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil
      @template.content_tag(:div, class: "space-y-1") { @template.safe_join([box, hint_el].compact) }
    end

    # Buttons
    def submit_btn(text, style, **opts)
      klass =
        case style
        when :primary
          %w[inline-flex items-center gap-2 rounded-lg bg-emerald-600 px-4 py-2 font-semibold text-white transition hover:bg-emerald-500 focus:outline-none focus-visible:ring-4 focus-visible:ring-emerald-500/25]
        when :secondary
          %w[inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2 font-medium text-gray-700 transition hover:bg-gray-50 focus:outline-none focus-visible:ring-4 focus-visible:ring-emerald-500/20]
        when :danger
          %w[inline-flex items-center gap-2 rounded-lg bg-red-600 px-4 py-2 font-semibold text-white transition hover:bg-red-500 focus:outline-none focus-visible:ring-4 focus-visible:ring-red-500/25]
        end.join(" ")

      submit(text, { class: klass, data: { turbo: true } }.merge(opts))
    end

    # Errors
    def error_text(method)
      return "".html_safe unless object.respond_to?(:errors) && object.errors[method].present?
      @template.content_tag(:p, object.errors.full_messages_for(method).first,
                            id: error_id(method), class: "text-xs text-red-600")
    end

    def error_id(method) = "#{object_name}_#{method}_error"
  end
end
