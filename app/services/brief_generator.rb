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

    # Per RubyLLM docs: create chat, set system instructions, then ask with the user content
    chat = RubyLLM.chat(
      model: (Rails.application.credentials.dig(:openai, :chat_model) || RubyLLM.config.default_model)
    )
    chat.with_instructions(prompt.system.to_s.strip, replace: true)

    # Optional: control creativity
    # chat = chat.with_temperature(0.4)

    response = chat.ask(prompt.user.to_s.strip)
    # response is a RubyLLM::Message; normalize to your expected hash-ish structure
    raw_h = {
      content:       response.content.to_s,
      model:         (response.respond_to?(:model_id) ? response.model_id : nil),
      usage:         {
        input_tokens:  (response.respond_to?(:input_tokens)  ? response.input_tokens  : nil),
        output_tokens: (response.respond_to?(:output_tokens) ? response.output_tokens : nil),
        total_tokens:  (response.respond_to?(:input_tokens) && response.respond_to?(:output_tokens) ?
                          (response.input_tokens.to_i + response.output_tokens.to_i) : nil)
      }
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