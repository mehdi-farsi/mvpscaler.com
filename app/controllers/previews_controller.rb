class PreviewsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def show
    @project = current_user.projects.find_by!(slug: params[:project_id])
    @landing = @project.active_landing
    @device  = params[:device].in?(%w[desktop mobile]) ? params[:device] : "desktop"
  end
end
