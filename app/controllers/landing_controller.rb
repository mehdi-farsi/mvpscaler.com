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

    render partial: "landing/edit_frame"
    # render partial: "landing/edit_panel", locals: { project: @project, landing: @landing, template: @template }
  end

  # Persist settings and respond via Turbo Stream (no full reload)
  def update
    @template = LandingTemplate.find(@landing.template_key)

    incoming = params.fetch(:settings_flat, {}).permit!.to_h
    filtered = whitelist_by_template(incoming, @template)

    # Merge into existing settings
    new_settings = @landing.settings.deep_merge(filtered)

    pp ?1*100, @landing.settings, ?1*100, filtered, ?1*100
    @landing.update!(settings: new_settings)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("save_notice",
                                                  partial: "landing/save_notice")
      end
      format.html { redirect_to edit_project_landing_path(@project),
                                notice: "Settings updated." }
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
  def whitelist_by_template(flat_hash, template, allow_clear: false)
    out = Hash.new { |h, k| h[k] = {} }

    flat_hash.each do |path, val|
      bucket, *rest = path.to_s.split(".")
      next if bucket.blank? || rest.empty?

      key = rest.join(".") # support nested like general.background_image_webp

      # Skip blank values unless you explicitly want to allow clearing
      if !allow_clear
        next if val.is_a?(String) && val.strip == ""
      end

      # Only accept fields that exist in this template
      next unless template.supports?(bucket, key)

      out[bucket][key] = (allow_clear && val == "__clear__") ? nil : val
    end

    out
  end
end
