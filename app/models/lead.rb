class Lead < ApplicationRecord
  NORMALIZED_EMAIL = URI::MailTo::EMAIL_REGEXP

  belongs_to :project

  validates :email, presence: true, format: { with: NORMALIZED_EMAIL }
  validates :email, uniqueness: { scope: :idea_slug, case_sensitive: false }

  before_validation :normalize

  private

  def normalize
    self.email = email.to_s.strip.downcase
  end
end