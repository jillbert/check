class RsvpsController < ApplicationController

include ApplicationHelper
include RsvpsHelper

def show
	@rsvp = Rsvp.find(params[:id])
  @guests = []
  (@rsvp.guests_count).times do 
    @guests << Rsvp.new
  end
end

def check_in
	@rsvp = Rsvp.find(params[:id])
  @guest_to_check_in = params[:guest_id]
	if makeRSVP(@rsvp)
		@rsvp.update_attribute(:attended, true)
		respond_to do |format|
		  format.js {}
		end
	else
	end
end

def new_rsvp_check_in
  @rsvp = new_rsvp(params[:rsvp])
  if @rsvp
    respond_to do |format|
      format.js {}
    end
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

