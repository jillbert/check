class RsvpsController < ApplicationController

include ApplicationHelper
include RsvpsHelper

def show
	@rsvp = Rsvp.find(params[:id])
  @guests = []
  (@rsvp.guests_count - @rsvp.guests.count).times do 
   guest = Rsvp.new
   guest.build_person
   @guests << guest
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

def create
  @rsvp = Rsvp.new(rsvp_params)
  if @rsvp.save
    redirect_to rsvp_path(params[:rsvp][:host_id])
  else
    render rsvp_path(params[:rsvp][:host_id])
  end
end

# def new_rsvp_check_in
#   @rsvp = new_rsvp(params[:rsvp])
#   @guest_id = params[:rsvp][:guest_id]
#   if @rsvp
#     respond_to do |format|
#       format.js {}
#     end
#   end
# end

private 
  def rsvp_params
    params.require(:rsvp).permit(
      :nation_id,
      :event_id,
      :rsvpNBID,
      :guests_count,
      :canceled,
      :host_id,
      :volunteer, 
      :is_private, 
      :shift_ids,
      :attended, person_attributes: [:id, :first_name, :last_name, :email, :phone_number])
  end

end

