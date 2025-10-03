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
        label_el = label(method, label || method.to_s.humanize, class: "block text-sm font-medium text-gray-700 mb-1")
        field_el = input_with_chrome(method, input_helper, *args, icon:, reveal:, **opts)
        hint_el  = hint ? @template.content_tag(:p, hint, class: "mt-1 text-xs text-gray-500") : "".html_safe
        error_el = error_text(method)
        @template.safe_join([label_el, field_el, hint_el, error_el])
      end
    end

    def input_with_chrome(method, input_helper, *args, icon: nil, reveal: false, **opts)
      has_error = object.respond_to?(:errors) && object.errors[method].present?

      base_classes = [
        "block w-full rounded-lg border bg-white px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm",
        "transition focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500"
      ]
      base_classes << "border-gray-300"
      base_classes << "border-red-500 focus:ring-red-500/20 focus:border-red-500" if has_error

      # If we render with an icon or reveal button, wrap in a flex container
      wrapper_classes = "relative flex items-stretch"

      input_opts = { class: [opts.delete(:class), base_classes.join(" ")].compact.join(" "),
                     aria: { invalid: has_error ? "true" : "false",
                             describedby: described_by_id(method, has_error) }.compact }

      # Build the input element itself
      field =
        if input_helper == :select
          select(method, *args, **input_opts)
        else
          public_send(input_helper, method, **input_opts.merge(args[0] || {}))
        end

      # Optional leading icon
      icon_el = if icon
                  @template.content_tag(:span,
                                        @template.content_tag(:i, "", class: "bi bi-#{icon}"),
                                        class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400"
                  ) +
                    # pad the input-left
                    @template.javascript_tag("void(0)") # noop; keeps safe_join alignment
                end

      # Adjust padding if icon present
      field = field.sub('px-3', 'pl-9 pr-3') if icon

      # Optional password reveal button (Stimulus hook)
      if reveal
        field = @template.content_tag(:div, class: wrapper_classes, data: { controller: "reveal" }) do
          @template.safe_join([
                                (icon ? @template.content_tag(:span, @template.content_tag(:i, "", class: "bi bi-#{icon}"), class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400") : "".html_safe),
                                field,
                                @template.content_tag(:button, type: "button",
                                                      class: "absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600",
                                                      data: { action: "reveal#toggle" }) do
                                  @template.content_tag(:i, "", class: "bi bi-eye")
                                end
                              ])
        end
      else
        # Wrap only if we had an icon
        field = @template.content_tag(:div, class: wrapper_classes) do
          @template.safe_join([
                                (icon ? @template.content_tag(:span, @template.content_tag(:i, "", class: "bi bi-#{icon}"), class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400") : "".html_safe),
                                field
                              ])
        end
      end

      field
    end

    def error_text(method)
      return "".html_safe unless object.respond_to?(:errors) && object.errors[method].present?
      @template.content_tag(:p, object.errors.full_messages_for(method).first, id: error_id(method), class: "mt-1 text-xs text-red-500")
    end

    def described_by_id(method, has_error)
      has_error ? error_id(method) : nil
    end

    def error_id(method)
      "#{object_name}_#{method}_error"
    end
  end
end
