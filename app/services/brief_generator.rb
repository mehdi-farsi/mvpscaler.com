class BriefGenerator
  class ParseError < StandardError; end

  def initialize(brief, use_cached: false)
    @brief = brief
    @use_cached = use_cached
  end

  def call
    if @use_cached && @brief.raw_response.present?
      json = extract_json(@brief.raw_response)
      persist(json, model: @brief.model_used, usage: @brief.usage)
      return true
    end

    prompt = BriefPromptBuilder.new(@brief)

    # RubyLLM.chat expects a single input string, not messages:
    combined_input = <<~PROMPT
      [SYSTEM]
      #{prompt.system.to_s.strip}

      [USER]
      #{prompt.user.to_s.strip}
    PROMPT

    response = RubyLLM.chat(
      model: (Rails.application.credentials.dig(:openai, :chat_model) || RubyLLM.config.default_chat_model),
      input: combined_input
    # extra: { temperature: 0.4, max_output_tokens: 900 } # optional vendor params if you use them
    )

    # Normalize to a hash with content/model/usage like before
    content_str = response.respond_to?(:to_s) ? response.to_s : response.to_json
    raw_h = {
      content: content_str,
      model:   (response.respond_to?(:model) ? response.model : (RubyLLM.config.default_chat_model rescue nil)),
      usage:   (response.respond_to?(:usage) ? response.usage : nil)
    }

    json = extract_json(raw_h)
    persist(json, model: raw_h[:model], usage: raw_h[:usage], raw: raw_h)
    true

  rescue JSON::ParserError, ParseError
    if defined?(raw_h)
      @brief.update!(
        raw_response: raw_h,
        model_used:   raw_h[:model],
        usage:        raw_h[:usage],
        status:       "error"
      )
    end
    raise
  end

  private

  def extract_json(raw)
    content = if raw.is_a?(Hash)
                raw[:content] || raw["content"] || raw.dig(:choices, 0, :message, :content)
              else
                raw.to_s
              end
    raise ParseError, "No content" if content.blank?

    body = content.strip
    begin
      JSON.parse(body)
    rescue JSON::ParserError
      body = body[/\{.*\}/m]
      raise ParseError, "Could not parse JSON" unless body
      JSON.parse(body)
    end
  end

  def persist(json, model:, usage:, raw: nil)
    @brief.update!(
      outputs:      json["copy"],
      theme:        json["theme"],
      model_used:   model,
      usage:        usage,
      raw_response: raw.presence || @brief.raw_response,
      status:       "generated"
    )
  end
end
