class Lead < ApplicationRecord
  NORMALIZED_EMAIL = URI::MailTo::EMAIL_REGEXP

  validates :email, presence: true, format: { with: NORMALIZED_EMAIL }
  validates :email, uniqueness: { scope: :idea_slug, case_sensitive: false }

  before_validation :normalize

  private

  def normalize
    self.email = email.to_s.strip.downcase
    self.idea_slug ||= "mvpscaler" # you can pass a different slug per campaign later
  end
end