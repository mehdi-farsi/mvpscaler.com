class AppController < ApplicationController
  layout "dashboard"

  default_form_builder App::FormBuilder
end