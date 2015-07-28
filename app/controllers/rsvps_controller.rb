class RsvpsController < ApplicationController

include ApplicationHelper
include RsvpsHelper
def show
	@rsvp = Rsvp.find(params[:id])
end

def check_in
	@rsvp = Rsvp.find(params[:id])
	if makeRSVP(@rsvp)
		@rsvp.update_attribute(:attended, true)
		respond_to do |format|
		  format.js {}
		end
	else
	end
end

private 
  def rsvp_params
    params.require(:rsvp).permit(
      :nation_id,
      :event_id,
      :rsvpNBID,
      :personNBID,
      :first_name,
      :last_name,
      :email,
      :guests_count,
      :canceled,
      :attended)
  end

end

