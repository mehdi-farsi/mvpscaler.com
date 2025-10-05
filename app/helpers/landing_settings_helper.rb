module LandingSettingsHelper
  def settings_value(landing, path, default = nil)
    keys = path.to_s.split(".")
    keys.reduce(landing.settings) { |acc, k| acc.is_a?(Hash) ? acc[k] : nil } || default
  end

  def settings_input_name(path)
    "landing[settings]" + path.to_s.split(".").map { |k| "[#{k}]" }.join
  end

  def settings_grouped_fields(template)
    (template.fields || {}).group_by { |path, _| path.to_s.split(".").first }
  end

  def render_settings_field(landing, path, meta)
    meta = meta.with_indifferent_access
    type  = meta[:type].to_s
    label = meta[:label].presence || path.to_s.split(".").last.humanize
    hint  = meta[:hint].to_s.presence
    rows  = (meta[:rows].presence || 4).to_i
    choices = Array(meta[:choices])
    value = settings_value(landing, path, meta[:default])
    name  = settings_input_name(path)
    id    = "setting_" + path.to_s.gsub(".", "_")

    content_tag(:div, class: "mb-4") do
      label_el = label_tag(id, label, class: "block text-sm font-medium text-gray-700 mb-1")

      field_el =
        case type
        when "text", ""
          text_field_tag(name, value, id: id,
                         class: "block w-full rounded-lg border border-gray-300 px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500")
        when "longtext"
          text_area_tag(name, value, id: id, rows: rows,
                        class: "block w-full rounded-lg border border-gray-300 px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500")
        when "color"
          content_tag(:div, class: "flex items-center gap-3") do
            picker = tag.input(type: :color, id: id, value: (value.presence || "#ffffff"),
                               class: "h-10 w-12 rounded border border-gray-300 p-1 bg-white")
            hex = text_field_tag(name, value, id: "#{id}_hex",
                                 placeholder: "#RRGGBB or empty",
                                 class: "flex-1 rounded-lg border border-gray-300 px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500",
                                 data: { controller: "color-sync", color_sync_target: "hex", color_sync_picker_id: id })
            picker + hex
          end
        when "image_asset"
          datalist_id = "#{id}_choices"
          datalist = content_tag(:datalist, choices.map { |c| content_tag(:option, nil, value: c) }.join.html_safe, id: datalist_id)
          input = text_field_tag(name, value, id: id, list: datalist_id,
                                 placeholder: "asset filename",
                                 class: "block w-full rounded-lg border border-gray-300 px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500")
          input + datalist
        else
          text_field_tag(name, value, id: id,
                         class: "block w-full rounded-lg border border-gray-300 px-3 py-2 text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-4 focus:ring-emerald-500/30 focus:border-emerald-500")
        end

      hint_el = hint ? content_tag(:p, hint, class: "mt-1 text-xs text-gray-500") : "".html_safe
      safe_join([label_el, field_el, hint_el])
    end
  end
end
