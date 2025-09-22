class LeadsController < ApplicationController
  def create
    @lead = Lead.new(lead_params)

    pp ?1*100, @lead.valid?, @lead.errors.full_messages

    if @lead.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path, notice: "Thanks. You are on the list." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cta_form", partial: "landing/form", locals: { lead: @lead }) }
        format.html { redirect_to root_path, alert: @lead.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:email, :idea_slug, :source)
  end
end
