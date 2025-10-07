class ApplyBriefToLanding
  def initialize(landing:, brief:)
    @landing  = landing
    @brief    = brief
    @template = LandingTemplate.find(@landing.template_key)
  end

  def call
    # 1) Start from FULL template defaults (includes blank/nil keys)
    defaults = LandingTemplate.defaults_for(@landing.template_key).deep_dup

    # 2) Layer existing landing settings (preserve prior edits)
    settings = defaults.deep_merge(@landing.settings.presence || {})

    # 3) Extract AI data from brief
    data = @brief.try(:ai_output_json).presence ||
           {
             "copy"    => @brief.outputs,
             "colors"  => (@brief.theme || {}),
             "buttons" => (@brief.theme || {})["buttons"],
             "general" => (@brief.theme || {})["backgrounds"]
           }
    data = data.compact

    # 4) Overlay AI data, but only where the template supports it
    merge_bucket!(settings, data, "copy")
    merge_bucket!(settings, data, "colors")
    merge_bucket!(settings, data, "buttons")
    merge_bucket!(settings, data, "general")

    # 5) Persist on the landing row
    @landing.update!(settings: settings)
  end

  private

  def merge_bucket!(settings, data, bucket)
    return unless data[bucket].is_a?(Hash)
    settings[bucket] ||= {}
    data[bucket].each do |k, v|
      next if v.blank?
      settings[bucket][k] = v if @template.supports?(bucket, k)
    end
  end
end
