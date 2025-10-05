class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    project = Onboarding::ProvisionAfterSignup.new(user: resource).call
    new_project_brief_path(project) # /projects/:slug/briefs/new
  rescue => e
    Rails.logger.error("[Onboarding] #{e.class}: #{e.message}")
    super
  end
end
