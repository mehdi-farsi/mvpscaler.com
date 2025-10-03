class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.from_google(auth)

    if @user.persisted?
      sign_in(@user) # do the login
      redirect_to dashboard_path
    else
      redirect_to new_user_session_path, alert: "Google authentication failed."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Authentication failed."
  end
end