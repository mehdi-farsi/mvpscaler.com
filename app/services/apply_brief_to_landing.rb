class ApplyBriefToLanding
  def initialize(landing:, brief:)
    @landing  = landing
    @brief    = brief
    @template = LandingTemplate.find(@landing.template_key)
    raise ArgumentError, "Unknown template #{@landing.template_key}" unless @template
  end

  def call
    # 1) Start from full defaults so shape is complete
    defaults = @template.default_settings.deep_dup

    # 2) Layer existing saved settings to preserve prior edits
    settings = defaults.deep_merge(@landing.settings.presence || {})

    # 3) Extract brief JSON (prefer raw JSON stored; fall back to legacy split fields)
    data = @brief.try(:ai_output_json).presence || legacy_fallback_from_brief

    # 4) Overlay data onto settings, only for whitelisted keys in this template
    @template.supported_buckets.each do |bucket|
      merge_bucket!(settings, data, bucket)
    end

    # 5) Persist
    @landing.update!(settings: settings)
  end

  private

  def legacy_fallback_from_brief
    theme   = @brief.theme || {}
    buttons = theme["buttons"] || {}
    general = theme["backgrounds"] || {}

    {
      "copy"    => @brief.outputs || {},
      "colors"  => theme.slice("accent", "accent_alt", "right_panel", "text_light", "text_muted"),
      "buttons" => buttons.slice("primary_bg", "primary_text"),
      "general" => general
    }.compact
  end

  def merge_bucket!(settings, data, bucket)
    return unless data[bucket].is_a?(Hash)
    settings[bucket] ||= {}

    data[bucket].each do |k, v|
      next if v.nil? || (v.respond_to?(:empty?) && v.empty?)
      if @template.supports?(bucket, k.to_s)
        settings[bucket][k.to_s] = v
      end
    end
  end
end
