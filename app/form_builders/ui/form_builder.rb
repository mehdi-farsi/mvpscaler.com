# frozen_string_literal: true

module Ui
  class FormBuilder < ActionView::Helpers::FormBuilder
    #
    # Public API (you’ll use these in templates):
    #   f.text_field_row :name, label: "Your name", hint: "Real name preferred", icon: "person"
    #   f.email_field_row :email, label: "Email", icon: "envelope"
    #   f.password_field_row :password, label: "Password", icon: "lock", reveal: true
    #   f.text_area_row :bio, label: "About you", rows: 4
    #   f.select_row :role, [["Admin","admin"],["User","user"]], label: "Role"
    #   f.check_box_row :tos, label: "I agree to the Terms"
    #   f.submit_primary "Create account"
    #

    # ---------- Row helpers (with label, input, hint, errors) ----------

    def text_field_row(method, **opts)
      input_row(method, :text_field, **opts)
    end

    def email_field_row(method, **opts)
      input_row(method, :email_field, **opts)
    end

    def password_field_row(method, reveal: false, **opts)
      input_row(method, :password_field, reveal:, **opts)
    end

    def text_area_row(method, **opts)
      input_row(method, :text_area, **opts)
    end

    def select_row(method, choices, **opts)
      input_row(method, :select, choices, **opts)
    end

    def check_box_row(method, label: nil, hint: nil, **opts)
      @template.content_tag(:div, class: "mb-4") do
        box = check_box(method, **merge_base_input_options(method, opts))
        lbl = label(method, label || method.to_s.humanize, class: "ml-2 text-sm text-gray-700")
        error = error_text(method)
        hint_el = hint ? @template.content_tag(:p, hint, class: "mt-1 text-xs text-gray-500") : "".html_safe
        @template.safe_join([
                              @template.content_tag(:label, @template.safe_join([box, lbl]), class: "inline-flex items-center"),
                              hint_el,
                              error
                            ])
      end
    end

    # ---------- Buttons ----------

    def submit_primary(text, **opts)
      classes = [
        "inline-flex items-center gap-2 rounded-lg bg-emerald-600 px-4 py-2",
        "font-semibold text-white shadow-sm transition hover:bg-emerald-500 focus:outline-none",
        "focus-visible:ring-4 focus-visible:ring-emerald-500/30"
      ].join(" ")

      @template.content_tag(:div, class: "mt-6") do
        submit(text, { class: classes, data: { turbo: true } }.merge(opts))
      end
    end

    def submit_secondary(text, **opts)
      classes = [
        "inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2",
        "font-medium text-gray-700 shadow-sm transition hover:bg-gray-50 focus:outline-none",
        "focus-visible:ring-4 focus-visible:ring-emerald-500/30"
      ].join(" ")

      @template.content_tag(:div, class: "mt-6") do
        submit(text, { class: classes, data: { turbo: true } }.merge(opts))
      end
    end

    # ---------- Internals ----------

    private

    def input_row(method, input_helper, *args, label: nil, hint: nil, icon: nil, reveal: false, **opts)
      @template.content_tag(:div, class: "mb-4") do
        label_el = label(method, label || method.to_s.humanize, class: "block text-sm font-medium text-gray-200 mb-1")
        field_el = input_with_chrome(method, input_helper, *args, icon:, reveal:, **opts)
        hint_el  = hint ? @template.content_tag(:p, hint, class: "mt-1 text-xs text-gray-400") : "".html_safe
        error_el = error_text(method)
        @template.safe_join([label_el, field_el, hint_el, error_el])
      end
    end

    def input_with_chrome(method, input_helper, *args, icon: nil, reveal: false, **opts)
      has_error = object.respond_to?(:errors) && object.errors[method].present?

      base_classes = %w[
        block w-full rounded-lg border px-3 py-2 shadow-sm transition
        focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500
      ]

      # Dark theme styles for the auth card
      base_classes += %w[
        bg-gray-800 text-white placeholder-gray-400 border-gray-700
      ]
      base_classes += %w[border-red-500 focus:ring-red-500/20 focus:border-red-500] if has_error

      input_opts = {
        class: [opts.delete(:class), base_classes.join(" ")].compact.join(" "),
        aria: {
          invalid: (has_error ? "true" : "false"),
          describedby: (has_error ? error_id(method) : nil)
        }.compact
      }

      field =
        if input_helper == :select
          select(method, *args, **input_opts)
        else
          public_send(input_helper, method, **input_opts.merge(args[0] || {}))
        end

      # If we render with an icon or reveal button, wrap in relative container
      wrapper_classes = "relative flex items-stretch"

      # Left icon
      left_icon = if icon
                    @template.content_tag(:span,
                                          @template.content_tag(:i, "", class: "bi bi-#{icon}"),
                                          class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400"
                    )
                  else
                    "".html_safe
                  end

      # Adjust padding if icon
      field = field.sub('px-3', 'pl-10 pr-3') if icon

      # Right reveal button (password)
      right_btn = if reveal
                    @template.content_tag(:button, type: "button",
                                          class: "absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-200",
                                          data: { action: "reveal#toggle" }) do
                      @template.content_tag(:i, "", class: "bi bi-eye")
                    end
                  else
                    "".html_safe
                  end

      @template.content_tag(:div, class: wrapper_classes, data: (reveal ? { controller: "reveal" } : {})) do
        @template.safe_join([left_icon, field, right_btn])
      end
    end

    def error_text(method)
      return "".html_safe unless object.respond_to?(:errors) && object.errors[method].present?
      @template.content_tag(:p, object.errors.full_messages_for(method).first, id: error_id(method), class: "mt-1 text-xs text-red-400")
    end

    def error_id(method)
      "#{object_name}_#{method}_error"
    end
  end
end
