class RsvpsController < ApplicationController

include ApplicationHelper
include RsvpsHelper
include PeopleHelper

before_filter :has_current_site_and_event

def index
  @rsvps = Rsvp.where(event_id: session[:current_event], host_id: nil)
  if @rsvps.size > 0
    @rsvps.order( 'last_name DESC')
  end
end

def cache 
  if session[:current_event]
    create_cache
    redirect_to rsvps_path
  else
    redirect_to choose_event_path
  end
end

def show
	@rsvp = Rsvp.find(params[:id])
  @guests = []
  (@rsvp.guests_count - @rsvp.guests.count).times do 
   guest = Rsvp.new
   guest.build_person
   @guests << guest
  end
end

def new
  @rsvp = Rsvp.new
  @rsvp.build_person
end

def create
  @rsvp = Rsvp.new(rsvp_params)
  if @rsvp.save
    @rsvp.person.update_attribute('nbid', send_person_to_nationbuilder(@rsvp.person))
    new_rsvp_id = send_rsvp_to_nationbuilder(@rsvp)
    @rsvp.update_attribute('rsvpNBID', new_rsvp_id )
    if params[:rsvp][:host_id].to_i > 0
      redirect_to rsvp_path(params[:rsvp][:host_id])
    else
      redirect_to everyone_path
    end
  else
    render rsvp_path(params[:rsvp][:host_id])
  end
end

def check_in
	@rsvp = Rsvp.find(params[:id])
	if send_rsvp_to_nationbuilder(@rsvp)
    @rsvp.update_attribute('attended', true)
		respond_to do |format|
		  format.js {}
		end
	else
	end
end

private 

  def has_current_site_and_event
    unless session[:current_site]
      redirect_to choose_site_path
    else
      unless session[:current_event]
        redirect_to choose_event_path
      else
        return true
      end
    end
  end
  
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
      :attended, 
      person_attributes: [:id, :first_name, :last_name, :email, :phone_number, :nbid])
  end

end

