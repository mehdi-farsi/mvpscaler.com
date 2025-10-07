# app/controllers/landing_controller.rb
class LandingController < ApplicationController
  # Public page uses the landing layout and skips CSRF
  layout :landing_layout, only: :show
  skip_before_action :verify_authenticity_token, only: :show

  # Dashboard actions must be authenticated (keep CSRF on)
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_project_for_dashboard, :set_landing_for_dashboard, only: [:edit, :update]

  # ---------- PUBLIC ----------
  def show
    @project = Project.find_by!(slug: params[:slug])
    @landing = @project.active_landing or (render plain: "No active landing", status: :not_found and return)
    tmpl      = @landing.template     or (render plain: "Unknown template",  status: :not_found and return)

    @lead = @project.leads.new
    render tmpl.partial
  end

  # ---------- DASHBOARD ----------
  # Render the inline editor into a Turbo Frame on the project page
  def edit
    @template = LandingTemplate.find(@landing.template_key)
    render partial: "landing/edit_panel", locals: { project: @project, landing: @landing, template: @template }
  end

  # Persist settings and respond via Turbo Stream (no full reload)
  def update
    @template = LandingTemplate.find(@landing.template_key)
    incoming  = params.require(:settings).permit!
    filtered  = whitelist_by_template(incoming.to_h, @template)

    @landing.update!(settings: @landing.settings.deep_merge(filtered))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("save_notice", partial: "landing/save_notice")
      end
      format.html { redirect_to edit_project_landing_path(@project), notice: "Settings updated." }
    end
  end

  private

  # Layout only for the public show
  def landing_layout
    return "landing" unless @landing&.template&.layout.present?
    @landing.template.layout
  end

  # Dashboard helpers
  def set_project_for_dashboard
    @project = current_user.projects.find_by!(slug: params[:project_id] || params[:slug])
  end

  def set_landing_for_dashboard
    @landing = @project.active_landing || @project.landings.first!
  end

  # Only allow fields that exist in the YAML template
  def whitelist_by_template(incoming, template)
    allowed = Hash.new { |h, k| h[k] = {} }
    template.fields.each_key do |full_key|
      bucket, name = full_key.split(".", 2)
      next unless incoming[bucket].is_a?(Hash)
      next unless incoming[bucket].key?(name)
      allowed[bucket][name] = incoming[bucket][name]
    end
    allowed
  end
end
