class LandingTemplate
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :name, :string
  attribute :partial, :string
  attribute :layout, :string
  attribute :description, :string
  attribute :fields, :any, default: {}

  class << self
    def all
      @all ||= begin
                 raw = Rails.application.config_for(:templates)
                 env_block = raw.is_a?(Hash) && raw.key?(Rails.env) ? raw[Rails.env] : raw
                 env_block.transform_values { |attrs| build(attrs) }
               end
    end

    def build(attrs)
      a = attrs.deep_symbolize_keys
      new(
        id: a[:id],
        name: a[:name],
        partial: a[:partial],
        layout: a[:layout],
        description: a[:description],
        fields: a[:fields] || {}
      )
    end

    def find(key)
      all[key.to_s]
    end

    def defaults_for(key)
      tmpl = find(key) or return {}
      flat = tmpl.fields.each_with_object({}) do |(path, meta), h|
        meta = meta || {}
        h[path.to_s] = meta["default"] || meta[:default]
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
  end
end
