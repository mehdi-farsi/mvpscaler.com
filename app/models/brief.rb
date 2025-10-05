class Brief < ApplicationRecord
  belongs_to :user
  belongs_to :project

  before_validation { self.status ||= "draft" }

  validates :audience, :problem, :product_idea, presence: true

  def locked?
    locked_at.present?
  end

  def lock!
    update!(locked_at: Time.current)
  end

  def generated?
    status.in?(%w[generated applied])
  end
end