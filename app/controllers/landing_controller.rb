class LandingController < ApplicationController
  def show
    @lead = Lead.new
  end
end
