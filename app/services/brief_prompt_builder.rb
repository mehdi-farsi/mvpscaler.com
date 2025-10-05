class BriefPromptBuilder
  def initialize(brief, template = "sober")
    @brief    = brief
    @template = LandingTemplate.find(template) # instance of LandingTemplate
  end

  def system
    <<~SYS
      You are a senior product marketer and designer.
      Task: generate landing copy and a cohesive color theme for the specified template.
      Output must be valid JSON only. No explanations or markdown.
    SYS
  end

  def user
    <<~USR
      Audience: #{@brief.audience}
      Problem: #{@brief.problem}
      Product idea: #{@brief.product_idea}

      Produce JSON with ONLY these top-level keys (if present in the template): #{json_top_keys.join(", ")}.

      Schema (only include keys that exist in this template):

      #{schema_block}

      Constraints:
      - Colors must be valid hex (#RRGGBB).
      - Copy must be concise and modern.
      - No em dashes.
      - Adapt tone to the audience:
        * Developers: clear and direct, minimal marketing.
        * Indie hackers: practical and results focused.
        * Founders: outcome driven and credible.
      - Keep badges unless clearly misfit.
      - Strict JSON. No markdown. No commentary.
    USR
  end

  private

  def json_top_keys
    @template.supported_buckets
  end

  # Build a per-template JSON schema block from YAML fields:
  def schema_block
    buckets = []

    if @template.groups["copy"].present?
      keys = @template.groups["copy"]
      buckets << %Q("copy": {\n#{keys.map { |k| %Q(  "#{k}": "string") }.join(",\n")}\n})
    end

    if @template.groups["colors"].present?
      keys = @template.groups["colors"]
      buckets << %Q("colors": {\n#{keys.map { |k| %Q(  "#{k}": "#RRGGBB") }.join(",\n")}\n})
    end

    if @template.groups["buttons"].present?
      keys = @template.groups["buttons"]
      buckets << %Q("buttons": {\n#{keys.map { |k| %Q(  "#{k}": "#{k =~ /text/ ? '#RRGGBB' : '#RRGGBB'}") }.join(",\n")}\n})
    end

    if @template.groups["general"].present?
      # We only request general fields that make sense for copy/colors (skip assets)
      # But we still show keys so LLM could give background colors, etc.
      keys = @template.groups["general"]
      buckets << %Q("general": {\n#{keys.map { |k| %Q(  "#{k}": "#{general_hint_for(k)}") }.join(",\n")}\n})
    end

    "{\n" + buckets.join(",\n") + "\n}"
  end

  def general_hint_for(key)
    if key.include?("bg")
      "#RRGGBB"
    else
      "string or null"
    end
  end
end
