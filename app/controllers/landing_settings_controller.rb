class LandingSettingsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def edit
    @project = current_user.projects.find_by!(slug: params[:project_id])
    @landing = @project.active_landing
    @template = @landing.template
  end

  def update
    @project = current_user.projects.find_by!(slug: params[:project_id])
    @landing = @project.active_landing
    if @landing.update(landing_params)
      redirect_to project_path(@project), notice: "Settings saved."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def landing_params
    params.require(:landing).permit(settings: {})
  end
end
