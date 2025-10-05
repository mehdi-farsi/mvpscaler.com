# frozen_string_literal: true
module Onboarding
  class ProvisionAfterSignup
    TEMPLATE_KEY = "sober".freeze

    def initialize(user:)
      @user = user
    end

    def call
      project = @user.projects.create!(
        name: "My Project",
        slug: unique_slug_for("my-project"),
        description: "A starter project created for you"
      )

      # Seed a Sober landing with YAML defaults
      project.landings.create!(
        name: "Sober default",
        template_key: TEMPLATE_KEY,
        active: true,
        settings: LandingTemplate.defaults_for(TEMPLATE_KEY)
      )

      project
    end

    private

    def unique_slug_for(base)
      candidate = base.parameterize
      i = 1
      while Project.exists?(slug: candidate)
        i += 1
        candidate = "#{base}-#{i}".parameterize
      end
      candidate
    end
  end
end
