require "ruby_llm"

RubyLLM.configure do |config|
  # Use Rails credentials (preferred over ENV for your setup)
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)

  # Optional: pick sensible defaults for your use case
  config.default_chat_model     = "gpt-4o-mini"
  config.default_image_model    = "gpt-image-1"
  config.default_embedding_model= "text-embedding-3-small"

  # Optional timeouts
  config.request_timeout = 30
end