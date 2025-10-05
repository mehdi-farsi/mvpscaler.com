class Landing < ApplicationRecord
  belongs_to :project

  validates :name, :template_key, presence: true
  validate  :template_key_supported

  before_validation :apply_template_defaults, on: :create
  before_save :enforce_single_active, if: -> { active_changed? && active? }

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
