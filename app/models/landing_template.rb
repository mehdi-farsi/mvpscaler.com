class LandingTemplate
  include ActiveModel::Model

  attr_accessor :id, :name, :partial, :layout, :description, :fields, :ui_sections

  def initialize(attributes = {})
    attrs = (attributes || {}).deep_symbolize_keys
    super(
      id:          attrs[:id],
      name:        attrs[:name],
      partial:     attrs[:partial],
      layout:      attrs[:layout],
      description: attrs[:description],
      fields:      (attrs[:fields] || {}).transform_keys!(&:to_s),
      ui_sections: Array(attrs[:ui_sections]) # [{key:, title:, fields:[...]}]
    )
  end

  class << self
    def all
      @all ||= load_templates
    end

    def find(key)
      all[key.to_s]
    end

    # Build a full default settings hash using the YAML defaults for each field.
    def defaults_for(template_key)
      tpl = find(template_key)
      raise ArgumentError, "Unknown template #{template_key}" unless tpl

      root = {}
      tpl.fields.each do |full_key, meta|
        bucket, name = full_key.split(".", 2)
        next if bucket.blank? || name.blank?
        (root[bucket] ||= {})
        assign_nested(root[bucket], name.split("."), meta["default"])
      end
      root
    end

    private

    def load_templates
      path = Rails.root.join("config", "templates.yml")
      data = File.exist?(path) ? (YAML.safe_load(File.read(path), aliases: true) || {}) : {}

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

    def assign_nested(hash, keys, value)
      k = keys.first
      if keys.length == 1
        hash[k] = value
      else
        hash[k] ||= {}
        assign_nested(hash[k], keys[1..], value)
      end
    end
  end

  # Buckets present in this template (intersection with our opinionated set)
  def supported_buckets
    @supported_buckets ||= begin
                             buckets = fields.keys.map { |fk| fk.split(".", 2).first }.uniq
                             buckets & %w[copy colors buttons general]
                           end
  end

  # Whitelist check for (bucket, key)
  def supports?(bucket, key)
    fields.key?("#{bucket}.#{key}")
  end

  # Authoritative editor sections from YAML (key, title, field_keys)
  def sections
    @sections ||= ui_sections.map do |sec|
      {
        key: sec[:key].to_s,
        title: (sec[:title].presence || sec[:key].to_s.humanize),
        field_keys: Array(sec[:fields]).map!(&:to_s) & fields.keys
      }
    end
  end

  # Convenience: default settings shaped for this template
  def default_settings
    self.class.defaults_for(id)
  end
end
