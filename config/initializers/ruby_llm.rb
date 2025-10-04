require "ruby_llm"

RubyLLM.configure do |config|
  # Use Rails credentials (preferred over ENV for your setup)
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)

  # Optional: pick sensible defaults for your use case
  config.default_model     = "gpt-4o-mini"
  # Optional timeouts
  config.request_timeout = 30

  config.log_file = "#{Rails.root}/tmp/ruby_llm.log"
  config.log_level = :info  # :debug, :info, :warn

  # Or use Rails logger
  config.logger = Rails.logger
end