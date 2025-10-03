# frozen_string_literal: true

# Use our custom builder everywhere
Rails.application.config.action_view.default_form_builder = "Ui::FormBuilder"