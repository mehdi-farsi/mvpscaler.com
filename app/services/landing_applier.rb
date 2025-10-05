class LandingApplier
  def initialize(project, brief)
    @project = project
    @brief   = brief
  end

  def call
    landing  = @project.active_landing or raise "No active landing"
    settings = landing.settings.deep_dup

    settings["copy"] ||= {}
    settings["copy"].merge!(@brief.outputs.to_h)

    theme   = @brief.theme.to_h
    colors  = (settings["colors"]  ||= {})
    buttons = (settings["buttons"] ||= {})
    general = (settings["general"] ||= {})

    colors["accent"]      = theme["accent"]
    colors["accent_alt"]  = theme["accent_alt"]
    colors["right_panel"] = theme["right_panel"]
    colors["text_light"]  = theme["text_light"]
    colors["text_muted"]  = theme["text_muted"]

    btn = theme["buttons"] || {}
    buttons["primary_bg"]   = btn["primary_bg"]
    buttons["primary_text"] = btn["primary_text"]

    bgs = theme["backgrounds"] || {}
    general["left_bg"]  = bgs["left"]
    general["right_bg"] = bgs["right"] || colors["right_panel"]

    landing.update!(settings:)
    @brief.update!(status: "applied")
  end
end
