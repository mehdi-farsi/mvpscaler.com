class ApplyBriefToLanding
  def initialize(landing:, brief:)
    @landing  = landing
    @brief    = brief
    @template = LandingTemplate.find(@landing.template_key)
  end

  def call
    settings = @template.default_settings.deep_dup

    data = @brief.try(:ai_output_json).presence || { "copy" => @brief.outputs, "colors" => (@brief.theme || {}), "buttons" => (@brief.theme || {})["buttons"], "general" => (@brief.theme || {})["backgrounds"] }
    data = data.compact

    # Copy over only keys allowed by the template
    merge_bucket!(settings, data, "copy")
    merge_bucket!(settings, data, "colors")
    merge_bucket!(settings, data, "buttons")
    merge_bucket!(settings, data, "general")

    @landing.update!(settings: settings)
  end

  private

  def merge_bucket!(settings, data, bucket)
    return unless data[bucket].is_a?(Hash)
    settings[bucket] ||= {}
    data[bucket].each do |k, v|
      next if v.blank?
      # only set if the template supports this bucket/key
      settings[bucket][k] = v if @template.supports?(bucket, k)
    end
  end
end