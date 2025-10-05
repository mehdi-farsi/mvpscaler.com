class Project < ApplicationRecord
  belongs_to :user
  has_many :landings, dependent: :destroy
  has_many :briefs, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_one_attached :logo

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :ensure_slug
  after_create :seed_default_landing!

  def active_landing
    landings.find_by(active: true)
  end

  def public_url
    Rails.application.routes.url_helpers.landing_show_path(slug)
  end

  def to_param = slug

  private

  def ensure_slug
    return if slug.present?
    base = name.to_s.parameterize
    candidate = base.presence || "project"
    i = 1
    while self.class.exists?(slug: candidate)
      i += 1
      candidate = "#{base}-#{i}"
    end
    self.slug = candidate
  end

  def seed_default_landing!
    landings.create!(
      name: "Sober default",
      template_key: "sober",
      active: true
    )
  end
end