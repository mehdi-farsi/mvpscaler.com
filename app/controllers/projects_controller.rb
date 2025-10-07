class ProjectsController < ApplicationController
  layout "dashboard"

  def new
    unless current_user.can_create_project?
      redirect_to dashboard_path, alert: "Upgrade to create more projects."
      return
    end
    @project = current_user.projects.new
  end

  def create
    unless current_user.can_create_project?
      redirect_to dashboard_path, alert: "Upgrade to create more projects."
      return
    end
    @project = current_user.projects.new(project_params)
    if @project.save!
      redirect_to project_path(@project), notice: "Project created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @project = current_user.projects.find_by!(slug: params[:id])
    @landing = @project.active_landing

    if turbo_frame_request? && params[:device].present?
      render partial: "projects/preview_panel", locals: { device: @device, project: @project }
    end
  end

  def edit
    @project = current_user.projects.find_by!(slug: params[:id])
  end

  def update
    @project = current_user.projects.find_by!(slug: params[:id])
    if @project.update(project_params)
      redirect_to project_path(@project), notice: "Project updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :slug, :description, :logo)
  end
end