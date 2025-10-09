# app/form_builders/app/form_builder.rb
# frozen_string_literal: true
module App
  class FormBuilder < ActionView::Helpers::FormBuilder
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

    # Minimal compact input (vertical layout)
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
          text_area(method, **input_opts.merge(rows: (opts[:rows] || 3), class: [input_opts[:class], "min-h-[88px]"].join(" ")))
        else
          public_send(input_helper, method, **input_opts.merge(args[0] || {}))
        end

      label_el = @template.content_tag(:label, label_text, class: "text-[13px] font-medium text-gray-700 block mb-1")
      hint_el  = hint.present? ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil
      error_el = has_error ? @template.content_tag(:p, object.errors.full_messages_for(method).first, id: error_id(method), class: "text-xs text-red-600 mt-1") : nil

      @template.safe_join([label_el, field, hint_el, error_el].compact)
    end

    def color_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      value      = object.try(method).presence || opts[:value]

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

      label_el = @template.content_tag(:label, label_text, class: "text-[13px] font-medium text-gray-700 block mb-1")
      row      = @template.content_tag(:div, class: "flex items-center gap-3") { chip + text }

      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil
      @template.safe_join([label_el, row, hint_el].compact)
    end

    def switch_row(method, label: nil, hint: nil, **opts)
      label_text = label || method.to_s.humanize
      input = check_box(method, **opts.merge(class: "peer sr-only"))
      slider = @template.content_tag(:span, "", class: "h-5 w-10 rounded-full bg-gray-300 ring-1 ring-inset ring-gray-200 relative transition
                        after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:shadow after:transition
                        peer-checked:bg-emerald-600 peer-checked:after:translate-x-5")

      switch = @template.content_tag(:label, input + slider, class: "inline-flex items-center cursor-pointer gap-3")
      label_el = @template.content_tag(:span, label_text, class: "text-[13px] font-medium text-gray-700 block mb-1")
      hint_el = hint ? @template.content_tag(:p, hint, class: "text-xs text-gray-500 mt-1") : nil

      @template.safe_join([label_el, switch, hint_el].compact)
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

    # Helpers
    def compact_input_classes(has_error: false)
      [
        "h-9 text-[13px] px-3 rounded-md",
        "ring-1 ring-inset",
        (has_error ? "ring-red-400 focus:ring-red-500" : "ring-gray-300 focus:ring-emerald-500"),
        "bg-white text-gray-900 placeholder-gray-400",
        "focus:outline-none transition w-full"
      ].join(" ")
    end

    def error_id(method) = "#{object_name}_#{method}_error"
  end
end