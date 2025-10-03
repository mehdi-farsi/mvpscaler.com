class ApplicationController < ActionController::Base
  layout :layout_by_resource
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added = [:name]
    devise_parameter_sanitizer.permit(:sign_up, keys: added)
    devise_parameter_sanitizer.permit(:account_update, keys: added)
  end

  def layout_by_resource
    if devise_controller?
      "auth" # use the auth layout above
    else
      "application"
    end
  end
end
