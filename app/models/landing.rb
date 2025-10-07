class Landing < ApplicationRecord
  belongs_to :project
  has_many :landing_assets, dependent: :destroy

  validates :name, :template_key, presence: true
  validate  :template_key_supported

  before_validation :apply_template_defaults, on: :create
  before_save :enforce_single_active, if: -> { active_changed? && active? }

  # If settings[field_key] contains a filename (e.g. "hero-bg.webp") use image_path.
  # If there's an uploaded file for that field, prefer the uploaded file’s URL.
  def asset_url_for(field_key)
    if (asset = landing_assets.find_by(field_key:))
      return Rails.application.routes.url_helpers.rails_blob_url(asset.file, only_path: true) if asset.file.attached?
    end

    # fallback to settings filename if present
    bucket, *rest = field_key.split(".")
    filename = settings.dig(bucket, *rest).to_s
    return "" if filename.blank?

    # absolute/URL?
    return filename if filename.start_with?("http", "/")

    # fingerprinted asset
    ApplicationController.helpers.image_path(filename)
  end

  def s(path, default = nil)
    path.to_s.split(".").reduce(settings) { |acc, k| acc.is_a?(Hash) ? acc[k] : nil } || default
  end

  def template
    LandingTemplate.find(template_key)
  end

  private

  def template_key_supported
    errors.add(:template_key, "is not supported") unless LandingTemplate.find(template_key)
  end

  def apply_template_defaults
    return if settings.present?
    defaults = LandingTemplate.defaults_for(template_key)
    self.settings = defaults if defaults.present?
  end

  def enforce_single_active
    Landing.where(project_id: project_id, active: true).where.not(id: id).update_all(active: false)
  end
end
