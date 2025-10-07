class BriefPromptBuilder
  def initialize(brief, template_key = "sober")
    @brief    = brief
    @template = LandingTemplate.find(template_key)
    raise ArgumentError, "Unknown template #{template_key}" unless @template
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

  def schema_block
    by_bucket = Hash.new { |h, k| h[k] = [] }
    @template.fields.each do |full_key, meta|
      bucket, name = full_key.split(".", 2)
      next unless @template.supported_buckets.include?(bucket)
      by_bucket[bucket] << %Q(  "#{name}": "#{type_hint_for(meta)}")
    end

    inner = @template.supported_buckets.map do |bucket|
      next if by_bucket[bucket].empty?
      %Q(") + bucket + %Q(": {\n#{by_bucket[bucket].join(",\n")}\n})
    end.compact

    "{\n" + inner.join(",\n") + "\n}"
  end

  def type_hint_for(meta)
    case meta["type"].to_s
    when "text", "longtext" then "string"
    when "color"            then "#RRGGBB"
    when "image_asset"      then "asset filename or null"
    when "boolean"          then "true or false"
    when "number", "int"    then "number"
    else                         "string or null"
    end
  end
end
