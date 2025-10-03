class User < ApplicationRecord
  # Classical Devise + OmniAuth
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  enum plan: { free: 0, pro: 1 }

  def self.from_google(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    user.email      = auth.info.email if user.has_attribute?(:email) && auth.info.email.present?
    user.name       = auth.info.name
    user.avatar_url = auth.info.image
    # ensure a password exists so user can use classical login/reset later
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?

    user.plan ||= :free
    user.save!
    user
  end
end
