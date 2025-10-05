class BriefsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project

  def new
    authorize_project!

    @brief = @project.briefs.build(
      audience:     "developers",
      problem:      "Spending weeks building without validating demand",
      product_idea: "An assistant that generates a landing, copy, and collects signups fast"
    )
  end

  def create
    authorize_project!

    @brief = @project.briefs.build(brief_params)

    if @brief.save
      # 1) generate copy/colors with your existing pipeline (fixed to RubyLLM chat API)
      BriefGenerator.new(brief: @brief).call

      # 2) hydrate the active landing’s settings from the brief
      ApplyBriefToLanding.new(
        landing: @project.active_landing || @project.landings.active.first || @project.landings.last,
        brief:   @brief
      ).call

      redirect_to project_path(@project), notice: "Your landing is ready. Tweak the copy or share your public link."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_project
    @project = current_user.projects.find_by!(slug: params[:project_id])
  end

  def authorize_project!
    # add Pundit/own check if you use it
  end

  def brief_params
    params.require(:brief).permit(:audience, :problem, :product_idea)
  end
end
