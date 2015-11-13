class RsvpsController < ApplicationController

  include ApplicationHelper
  include RsvpsHelper
  include PeopleHelper

  before_filter :has_current_site_and_event
  before_filter :get_event
  before_filter :is_owner, only: [:show]

  def index
    @rsvps = Rsvp.where(event_id: @current_event.id, host_id: nil)
    get_count
    if @rsvps.size > 0
      @rsvps.order( 'last_name DESC')
    end
  end

  def cache 
    create_cache
    redirect_to rsvps_path
  end

  def show
  	@rsvp = Rsvp.find(params[:id])
    @add_guests = add_guests(@rsvp)

  end

  def check_in
  	@rsvp = Rsvp.find(params[:id])
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
  	if nationbuilder_rsvp[:status]
      @rsvp.update_attribute('attended', true)
  		respond_to do |format|
  		  format.js {}
  		end
  	else
  	end
  end

  def sync
    @rsvps = Rsvp.where(event_id: @current_event.id).to_a
    @nb = check_sync
    @same = []


    @rsvps.each do |r|
      if r.rsvpNBID
        @nb.each do |n|
          if n['id'] == r.rsvpNBID
            @same << r
          end
        end
      end
    end

    @same.each do |s|
      @rsvps.delete(s)
      @nb.delete_if { |n| n['id'] == s.rsvpNBID }
    end

    @nb_person = []
    @nb.each do |n|
      @nb_person << get_person(n)
    end

    get_count

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
  
  def is_owner
    redirect_to(:root, flash: { error: "Sorry, you don't have access to this information"}) if current_user.nation.id != Rsvp.find(params[:id]).person.nation_id
  end
end

