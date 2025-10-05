class DashboardController < ApplicationController
  layout "dashboard"

  def show
    @projects = current_user.projects.order(created_at: :desc)
  end
end
