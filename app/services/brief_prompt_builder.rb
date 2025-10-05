class BriefPromptBuilder
  def initialize(brief)
    @brief = brief
  end

  # Keep your existing methods
  def system
    <<~SYS
      You are a senior product marketer and designer.
      Task: generate landing copy and a cohesive color theme.
      Output must be valid JSON only.
    SYS
  end

  def user
    <<~USR
      Audience: #{@brief.audience}
      Problem: #{@brief.problem}
      Product idea: #{@brief.product_idea}

      Produce JSON with:
      {
        "copy": {
          "headline": "...",
          "subheadline": "...",
          "paragraph_1": "...",
          "paragraph_2": "...",
          "badge_1": "100+ signups = Build it",
          "badge_2": "500+ signups = Banger",
          "badge_3": "< 100 = Move on, save time",
          "cta_title": "Get early access",
          "cta_sub": "Try MVPScaler and validate your next idea with confidence."
        },
        "theme": {
          "accent": "#059669",
          "accent_alt": "#0d9488",
          "right_panel": "#111827",
          "text_light": "#ffffff",
          "text_muted": "#9ca3af",
          "buttons": { "primary_bg": "#059669", "primary_text": "#ffffff" },
          "typography": { "heading": "Inter", "body": "Inter" },
          "backgrounds": { "left": null, "right": "#111827" }
        }
      }

      Constraints:
      - Colors must be valid hex (#RRGGBB).
      - Copy must be concise and modern.
      - No em dashes.
      - Adapt tone to the audience:
        * Developers: clear and direct, minimal marketing.
        * Indie hackers: practical and results focused.
        * Founders: outcome driven and credible.
      - Keep badges unless clearly misfit.
      - Output must be strict JSON. No markdown. No commentary.
    USR
  end

  # New: single string for RubyLLM.chat(input: ...)
  def combined
    <<~PROMPT
      [SYSTEM]
      #{system.strip}

      [USER]
      #{user.strip}
    PROMPT
  end
end
