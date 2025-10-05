# app/models/landing_template.rb
class LandingTemplate
  include ActiveModel::Model

  attr_accessor :id, :name, :partial, :layout, :description, :fields

  def initialize(attributes = {})
    attrs = (attributes || {}).deep_symbolize_keys
    super(
      id:          attrs[:id],
      name:        attrs[:name],
      partial:     attrs[:partial],
      layout:      attrs[:layout],
      description: attrs[:description],
      fields:      attrs[:fields] || {}
    )
  end

  class << self
    def all
      @all ||= load_templates
    end

    def find(key)
      all[key.to_s]
    end

    def defaults_for(key)
      tmpl = find(key) or return {}
      flat = (tmpl.fields || {}).each_with_object({}) do |(path, meta), h|
        meta = (meta || {}).with_indifferent_access
        h[path.to_s] = meta[:default]
      end
      unflatten(flat)
    end

    def unflatten(hash)
      result = {}
      hash.each do |path, value|
        next if value.nil?
        keys = path.split(".")
        last = keys.pop
        node = keys.inject(result) { |acc, k| acc[k] ||= {} }
        node[last] = value
      end
      result
    end

    def groups
      @groups ||= begin
                    grouped = Hash.new { |h,k| h[k] = [] }
                    fields.each_key do |full|
                      parts = full.to_s.split(".")
                      next unless parts.size >= 2
                      group = parts.first       # "copy", "colors", "buttons", "general"
                      key   = parts[1..].join(".") # support nested like general.background_image
                      grouped[group] << key
                    end
                    grouped
                  end
    end

    # Only the top-level buckets we support in prompts/mapping
    def supported_buckets
      groups.keys & %w[copy colors buttons general]
    end

    # Return a default settings hash shaped like the template (using your YAML defaults)
    def default_settings
      LandingTemplate.defaults_for(id)
    end

    # Whitelist: check a (bucket, key) pair is defined by this template
    def supports?(bucket, key)
      groups[bucket]&.include?(key)
    end

    private

    def load_templates
      path = Rails.root.join("config", "templates.yml")
      data = if File.exist?(path)
               YAML.safe_load(File.read(path), aliases: true) || {}
             else
               {}
             end

      # Priority: default: … → Rails.env → flat map
      source =
        if data.key?("default")
          data["default"]
        elsif data.key?(Rails.env)
          data[Rails.env]
        else
          data
        end

      (source || {}).each_with_object({}) do |(key, attrs), h|
        attrs ||= {}
        attrs = attrs.merge("id" => (attrs["id"].presence || key.to_s))
        h[key.to_s] = new(attrs)
      end
    end
  end
end
