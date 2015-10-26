class RsvpsController < ApplicationController

include ApplicationHelper
include RsvpsHelper
include PeopleHelper

before_filter :has_current_site_and_event
before_filter :get_event

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

  if @rsvp.guests.count < @rsvp.guests_count
    @guest = Rsvp.new
    @guest.build_person
  end
end

def new
  @rsvp = Rsvp.new
  @rsvp.build_person

  if params[:host_id]
    @host_id = params[:host_id]
  end

  respond_to do |f|
    f.html {}
    f.js {}
  end
end

def create
  @rsvp = Rsvp.new(rsvp_params)

  nationbuilder_person = send_person_to_nationbuilder(@rsvp.person)
  puts nationbuilder_person
  if nationbuilder_person[:status]
    @rsvp.person.update_attribute('nbid', nationbuilder_person[:id])
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp)
    puts nationbuilder_rsvp
    if nationbuilder_rsvp[:status]
      @rsvp.update_attribute('rsvpNBID', nationbuilder_rsvp[:id])

      @rsvp.save
      respond_to do |format|
        if params[:rsvp][:host_id]
          format.js {}
          format.html { redirect_to rsvp_path(params[:rsvp][:host_id]) }
        else
          format.js {redirect_to rsvp_path(@rsvp.id)}
          format.html {redirect_to rsvp_path(@rsvp.id) }
        end
      end

    else
      @rsvp.errors.add(:rsvp, nationbuilder_rsvp[:error])
      respond_to do |format|
        format.js { render status: 500 }
        format.html { redirect_to rsvp_path(params[:rsvp][:host_id]) }
      end
    end
  
  else
    @rsvp.errors.add(:person, nationbuilder_person[:error])
    respond_to do |format|
      format.js { render status: 500 }
      format.html { redirect_to rsvp_path(params[:rsvp][:host_id]) }
    end
  end

end


def check_in
	@rsvp = Rsvp.find(params[:id])
  @rsvp.update_attribute('attended', true)
	if send_rsvp_to_nationbuilder(@rsvp)
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

