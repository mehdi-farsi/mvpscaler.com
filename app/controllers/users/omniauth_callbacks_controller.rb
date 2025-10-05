class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.from_google(auth)

    if @user.persisted?
      sign_in(@user) # do the login

      begin
        project = Onboarding::ProvisionAfterSignup.new(user: @user).call

        redirect_to new_project_brief_path(project) # /projects/:slug/briefs/new
      rescue => e
        Rails.logger.error("[Onboarding] #{e.class}: #{e.message}")
        redirect_to dashboard_path
      end
    else
      redirect_to new_user_session_path, alert: "Google authentication failed."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Authentication failed."
  end
end