class LandingController < ApplicationController
  layout :landing_layout
  skip_before_action :verify_authenticity_token, only: :show

  def show
    @project = Project.find_by!(slug: params[:slug])
    @landing = @project.active_landing or (render plain: "No active landing", status: :not_found and return)
    tmpl = @landing.template or (render plain: "Unknown template", status: :not_found and return)
    @lead = @project.leads.new
    render tmpl.partial
  end

  private

  def landing_layout
    return "landing" unless @landing&.template&.layout.present?
    @landing.template.layout
  end
end
