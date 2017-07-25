class RsvpsController < ApplicationController
  include ApplicationHelper
  include RsvpsHelper
  include PeopleHelper

  before_filter :has_current_site_and_event
  before_filter :get_event
  before_filter :is_owner, only: [:show]

  def index
    if params[:query]
      @rsvps = Rsvp.includes(:person)
                   .where(event_id: @current_event.id, host_id: nil)
                   .where('lower(first_name) LIKE ? OR lower(last_name) LIKE ? OR lower(email) LIKE ?', "%#{params[:query].downcase}%", "%#{params[:query].downcase}%", "%#{params[:query].downcase}%")
                   .order("people.last_name desc")
    else
      @rsvps = Rsvp.includes(:person)
                   .where(event_id: @current_event.id, host_id: nil)
                   .order("people.last_name desc")
    end

    @letters = Rsvp.letters(@rsvps.pluck("people.last_name"))
    render layout: false if params[:query]

  end

  def new
    @page = 'new-rsvp'
    @rsvp = Rsvp.new
    @person = Person.new
    @host = Rsvp.find(params[:host_id]) if params[:host_id]
    @event = if params[:event_id]
               Event.find(params[:event_id])
             else
               @current_event
             end
   render layout: false
  end

  def create
    @rsvp = Rsvp.new(rsvp_params)
    if @rsvp.save
      @person = Person.find_or_create_by(email: rsvp_params[:email], nation_id: @rsvp.nation_id)
      if @host && @event
        @rsvp.update_attributes(person_id: @person.id, nation_id: @current_event.nation_id, guests_count: 0, host_id: @host.id, event_id: @event.id)
      else
        @rsvp.update_attributes(person_id: @person.id, nation_id: @current_event.nation_id, guests_count: 0, event_id: @event.id  )
      end

    end
    redirect_to rsvps_path
  end

  def cache
    # create_cache
    # redirect_to rsvps_path
    @current_event.update_attributes(sync_status: 'pending', sync_percent: 0, sync_date: DateTime.now)
    Resque.enqueue(Sync, params[:id], session[:current_site], session[:credential_id])

    respond_to do |format|
      format.json { render json: { status: 'started' } }
    end
  end

  def show
    @rsvp = Rsvp.find(params[:id])
    # check_nb_update(@rsvp.person)
    # @add_guests = add_guests(@rsvp)
    @guests = Rsvp.where(host_id: @rsvp.id)
    render layout: false
  end

  def check_in
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attributes(attended: true)
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
    if nationbuilder_rsvp[:status]
      respond_to do |format|
        format.js {}
      end
    end
  end

  def check_out
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attributes(attended: false)
    nationbuilder_rsvp = send_rsvp_to_nationbuilder(@rsvp, @rsvp.person)
    if nationbuilder_rsvp[:status]
      respond_to do |format|
        format.js {}
      end
    end
  end

  def sync
    Rsvp.sync(@current_event, session[:current_site])
    @rsvps = Rsvp.includes(:person).where(event_id: @current_event.id, host_id: nil).order("people.last_name desc")
    @letters = Rsvp.letters(@rsvps.pluck("people.last_name"))
    @rsvps.order('last_name DESC') unless @rsvps.empty?
    render layout: false
  end

  private

  def rsvp_params
    params.require(:rsvp).permit(:event_id, :guests_count, :canceled, :attended, :rsvpNBID, :nation_id, :volunteer, :is_private, :shift_ids, :host_id, :person_id, :ticket_type, :tickets_sold, :person, person_attributes: %i[first_name last_name email phone_number])
  end

  def has_current_site_and_event
    if session[:current_site] && session[:current_event] then true else redirect_to landing_path end
  end

  def is_owner
    if current_user.nation.id != Rsvp.find(params[:id]).person.nation_id
      begin
        redirect_to(:back, flash: { error: "Sorry, you don't have access to this information" })
      rescue ActionController::RedirectBackError
        redirect_to(:root, flash: { error: "Sorry, you don't have access to this information" })
      end
    end
  end
end
