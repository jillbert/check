class EventsController < ApplicationController

include ApplicationHelper
include EventsHelper

before_filter :has_session_info, :except => [:index, :choose_event, :find_rsvp]

  def index
    if session[:current_site]
      redirect_to :controller => 'events', :action => 'choose_event'
    else 
      response = token.get("/api/v1/sites", :headers => standard_headers, :params => { page: 1, per_page: 100});
      @sites = JSON.parse(response.body)["results"]
    end

  end

  def choose_event
    unless session[:current_site]
      session[:current_site] = params[:nation]
    end

    if session[:current_event]
      redirect_to :controller => 'events', :action => 'get_all'
    else
      token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events'
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100})
      @events = JSON.parse(response.body)["results"]
    end
  end

  def find_rsvp
    unless session[:current_event]
      session[:current_event] = params[:event]
      session[:current_event_name] = params[:name]
    end
    @event = session[:current_event]
  end

  def get_all
    e = Event.where(nation_id: session[:current_nation], eventNBID: session[:current_event]).first
    if e
      @rsvps = Rsvp.where(event_id: e.id).order( 'last_name ASC' )
    else
      create_cache
      # @current_page = (params[:page] || 1).to_i
      # response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, params: {page: @current_page})
      # @total_pages = JSON.parse(response.body)["total_pages"]
      # @rsvpsfullinfo = JSON.parse(response.body)
      # @rsvps = @rsvpsfullinfo["results"]

      # @persons = []
      # @rsvps.each do |r|
      #   response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
      #   person = JSON.parse(response.body)["person"]
      #   @persons << Person.from_hash(person)
      # end
    end
  end

  def update_cache
    create_cache
    redirect_to everyone_path, :notice => "Cache updated"
  end

  def create_cache
    
    event = nil
    e = Event.where(nation_id: session[:current_nation], eventNBID: session[:current_event])
    if e.size > 0
      event = e.first
    else
      event = Event.create!(nation_id: session[:current_nation], eventNBID: session[:current_event])
    end

    current_page = 1
    rsvpListfromNB = []
    response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, params: {page: current_page})
    total_pages = JSON.parse(response.body)["total_pages"]
    rsvpListfromNB << JSON.parse(response.body)["results"]
    while total_pages >= current_page
      current_page += 1
      response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, params: {page: current_page})
      rsvpListfromNB << JSON.parse(response.body)["results"]
    end

    @rsvps = []
    rsvpListfromNB.flatten!.each do |r|
      existentRSVP = Rsvp.where(event_id: event.id, rsvpNBID: r['id'], nation_id: session[:current_nation])
      if existentRSVP.size == 0
        response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
        person = JSON.parse(response.body)["person"]
        newrsvp = Rsvp.create!(
          nation_id: session[:current_nation],
          event_id: event.id,
          rsvpNBID: r['id'],
          personNBID: person['id'],
          first_name: person['first_name'],
          last_name: person['last_name'],
          email: person['email'],
          guests_count: r['guests_count'].to_i,
          canceled: r['canceled'],
          attended: r['attended']
        )
      end
    end
  end

  def find_person

    @params = createMatchParams(params[:first_name], params[:last_name], params[:email], params[:phone], params[:mobile])

    @personMatch = nil

    begin

      response = token.get("api/v1/people/match", :headers => standard_headers, :params => @params )

    rescue => ex

      redirect_to :controller => 'events', :action => 'find_rsvp', :event_id => session[:current_event], :params => @params
      flash[:error] = JSON.parse(ex.response.body)["message"]

    else

      person = JSON.parse(response.body)["person"]
      @personMatch = Person.from_hash(person)
      
      @rsvpFound = findRSVP(session[:current_event], @personMatch.id)
      if @rsvpFound
        flash[:success] = "RSVP found."
        rsvpidsearch = @rsvpFound['id']
        plusone = Guest.where(rsvpNBID: rsvpidsearch, eventNBID: session[:current_event], nationNBID: session[:current_nation])

        @plusonearray = []
        plusone.each do |n|
          begin
          response = token.get("api/v1/people/#{n.plusoneNBID}", :headers => standard_headers)
          rescue => ex
            puts ex
          else
            person = JSON.parse(response.body)["person"]
            @plusonearray << Person.from_hash(person)
          end
        end
      else
        flash[:error] = "#{@personMatch.name}'s RSVP does not exist. Would you like to check them in."
      end
    end

  end

  def new_rsvp
  end

  def make_new_rsvp

    @params = createMatchParams(params[:first_name], params[:last_name], params[:email], params[:phone], params[:mobile])
    
    begin

      response = token.get("api/v1/people/match", :headers => standard_headers, :params => @params )

    rescue
      newPersonParams = 
      {
        :person => {
          :email => params[:email],
          :last_name => params[:last_name],
          :first_name => params[:first_name],
          :phone => params[:phone],
          :mobile => params[:mobile]
        }
      }

      response = token.post('api/v1/people', :headers => standard_headers, :params => newPersonParams)
    end      

    id = JSON.parse(response.body)["person"]["id"]
    rsvpObject = makeRSVP(nil, session[:current_event], id.to_i, 0, "false", "false", "false", "true") 
    puts rsvpObject
    begin
      checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
    rescue => ex
        flash[:error] = ex.message.split('"validation_errors":')[1]
    else
      flash[:success] = "#{params['first_name']} #{params['last_name']} successfully added and checked in."
    end

    redirect_to :controller => 'events', :action => 'index'

  end

  def processCheckIn

    if params[:rsvp_id]
      rsvpObject = makeRSVP(params[:rsvp_id], session[:current_event], params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    else
      rsvpObject = makeRSVP(nil, session[:current_event], params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    end

    begin

      if params[:rsvp_id]
        checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/#{params[:rsvp_id]}", :headers => standard_headers, :body => rsvpObject.to_json)
      else
        checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
      end

    rescue => ex

      flash[:error] = ex

    else

      main_rsvp_id = JSON.parse(checkInResponse.body)["rsvp"]["id"]

      if params[:guests].to_i > 0
        (params[:guests].to_i).times do |n|

          name = "guest_" + "#{n}"
          inputted_guest = params[name.to_sym].to_hash

          if inputted_guest["first_name"] != "" && inputted_guest["last_name"] != "" && (inputted_guest["email"] != "" || inputted_guest["mobile"] != "")
            guest = Person.from_hash(inputted_guest)
            @params = {
              :person => {
                :first_name => guest.first_name,
                :last_name => guest.last_name,
                :email => guest.email,
                :mobile => guest.mobile,
                :recruiter_id => params[:person_id]
              }
            }

            begin
              response = token.put("/api/v1/people/push", :headers => standard_headers, :params => @params)
            rescue => ex
              flash[:error] = ex
            else
              guest_id = JSON.parse(response.body)["person"]["id"]

              putParams = {
                "rsvp" => {
                  "event_id" => session[:current_event].to_i,
                  "person_id" => guest_id,
                  "guests_count" => 0,
                  "volunteer" => false,
                  "private" => false,
                  "canceled" => false,
                  "attended" => true,
                  "shift_ids" => []
                }
              }

              begin
                  checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => putParams.to_json)
              rescue => ex 
                flash[:error] = ex
              else
                Guest.create(
                  :eventNBID => session[:current_event].to_i, 
                  :plusoneNBID => guest_id.to_i,
                  :nationNBID => session[:current_nation],
                  :nation_name => "#{session[:current_site]}", 
                  :rsvpNBID => main_rsvp_id.to_i
                )
              end
            end
          end

        end
      end
    end

      redirect_to :controller => 'events', :action => 'index', :event_id => session[:current_event]

  end

  def findRSVP(event, person)
    rsvpFound = nil

    rsvpresponse = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps", :headers => standard_headers, :params => { page: 1, per_page: 100 })
    rsvps = JSON.parse(rsvpresponse.body)["results"]

    rsvps.each do |rsvp|
      if rsvp['person_id'] == person
          rsvpFound = rsvp
      end
    end

    return rsvpFound

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

  def event_params
    params.require(:event).permit(:nation_id, :eventNBID)
  end

end