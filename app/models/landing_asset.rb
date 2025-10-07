class LandingAsset < ApplicationRecord
  belongs_to :landing
  has_one_attached :file

  validates :field_key, presence: true
end
