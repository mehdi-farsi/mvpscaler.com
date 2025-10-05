class BriefsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_brief, only: [:show, :generate, :reparse, :apply]
  layout "dashboard"

  def new
    if current_user.free_locked_brief?(@project)
      redirect_to project_path(@project), alert: "Your free brief is locked. Upgrade to create another."
      return
    end
    @brief = @project.briefs.new
  end

  def create
    @brief = @project.briefs.new(brief_params.merge(user: current_user))
    if @brief.save
      redirect_to project_brief_path(@project, @brief), notice: "Brief saved. Generate your copy and theme."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show; end

  def generate
    BriefGenerator.new(@brief).call
    @brief.lock! if current_user.free?
    redirect_to project_brief_path(@project, @brief), notice: "Copy and theme generated."
  rescue BriefGenerator::ParseError
    redirect_to project_brief_path(@project, @brief), alert: "The AI response could not be parsed. Try Reparse."
  end

  def reparse
    BriefGenerator.new(@brief, use_cached: true).call
    redirect_to project_brief_path(@project, @brief), notice: "Reparsed from stored response."
  rescue BriefGenerator::ParseError
    redirect_to project_brief_path(@project, @brief), alert: "Stored response could not be parsed."
  end

  def apply
    LandingApplier.new(@project, @brief).call
    redirect_to project_path(@project), notice: "Applied to your active landing."
  end

  private

  def set_project
    @project = current_user.projects.find_by!(slug: params[:project_id])
  end

  def set_brief
    @brief = @project.briefs.find(params[:id])
  end

  def brief_params
    params.require(:brief).permit(:audience, :problem, :product_idea)
  end
end
