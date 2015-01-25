class EventsController < ApplicationController

include ApplicationHelper
include EventsHelper

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
      redirect_to :controller => 'events', :action => 'find_rsvp'
    else
      token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events'
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100})
      @events = JSON.parse(response.body)["results"]
    end
  end

  def find_rsvp
    unless session[:current_event]
      session[:current_event] = params[:event]
    end
    @event = session[:current_event]
  end

  def get_all
    response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]['id']}/rsvps/", :headers => standard_headers)
    @rsvps = JSON.parse(response.body)["results"]

    @persons = []
    @rsvps.each do |r|
      response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
      person = JSON.parse(response.body)["person"]
      @persons << Person.from_hash(person)
    end
  end

  def find_person

    @params = createMatchParams(params[:first_name], params[:last_name], params[:email], params[:phone], params[:mobile])
    @event_id = params[:event_id]
    @personMatch = nil

    begin

      response = token.get("api/v1/people/match", :headers => standard_headers, :params => @params )

    rescue => ex

      redirect_to :controller => 'events', :action => 'find_rsvp', :event_id => @event_id, :params => @params
      flash[:error] = JSON.parse(ex.response.body)["message"]

    else

      person = JSON.parse(response.body)["person"]
      @personMatch = Person.from_hash(person)
      
      @rsvpFound = findRSVP(@event_id, @personMatch.id)
      if @rsvpFound
        flash[:success] = "RSVP found. Please update personal info and check in."
        rsvpidsearch = @rsvpFound.rsvp_id
        plusone = Guest.where(rsvpNBID: rsvpidsearch, eventNBID: @event_id, nationNBID: session[:current_nation])

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
        flash[:error] = "#{@personMatch.name}'s RSVP does not exist. Please update personal info, create an RSVP, and check them in."
      end
    end

  end

  def processCheckIn

    event_id = params[:event_id]

    if params[:rsvp_id]
      rsvpObject = makeRSVP(params[:rsvp_id], event_id, params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    else
      rsvpObject = makeRSVP(nil, event_id, params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    end

    begin

      if params[:rsvp_id]
        checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{event_id}/rsvps/#{params[:rsvp_id]}", :headers => standard_headers, :body => rsvpObject.to_json)
      else
        checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{event_id}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
      end

    rescue => ex

      flash[:error] = ex

    else

      main_rsvp_id = JSON.parse(checkInResponse.body)["rsvp"]["id"]

      if params[:guests].to_i > 0
        (params[:guests].to_i).times do |n|

          name = "guest_" + "#{n}"
          inputted_guest = params[name.to_sym].to_hash
          puts inputted_guest["first_name"] != ""
          puts inputted_guest["email"] != ""

          if inputted_guest["first_name"] != "" && inputted_guest["last_name"] != "" && (inputted_guest["email"] != "" || inputted_guest["mobile"] != "")
            guest = Person.from_hash(inputted_guest)
            @params = {
              :person => {
                :first_name => guest.first_name,
                :last_name => guest.last_name,
                :email => guest.email,
                :mobile => guest.mobile
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
                  "event_id" => event_id.to_i,
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
                  checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{event_id}/rsvps/", :headers => standard_headers, :body => putParams.to_json)
              rescue => ex 
                flash[:error] = ex
              else
                Guest.create(
                  :eventNBID => event_id.to_i, 
                  :plusoneNBID => guest_id.to_i,
                  :nationNBID => session[:current_nation],
                  :nation_name => "#{session[:current_site]}", 
                  :rsvpNBID => main_rsvp_id.to_i
                )
              end
            end
          else 
            flash[:error] = "Please complete all fields for #{inputted_guest["first_name"]}"
          end

        end
      end
    end

      redirect_to :controller => 'events', :action => 'index', :event_id => event_id

  end

  def findRSVP(event, person)
    rsvpFound = nil

    rsvpresponse = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]['id']}/rsvps", :headers => standard_headers, :params => { page: 1, per_page: 100 })
    rsvps = JSON.parse(rsvpresponse.body)["results"]

    rsvps.each do |rsvp|
      puts rsvp['person_id']
      puts person
      if rsvp['person_id'] == person
          rsvpFound = Rsvp.from_hash(rsvp)
      end
    end

    return rsvpFound

  end

end