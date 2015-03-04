class EventsController < ApplicationController

include ApplicationHelper
include EventsHelper

before_filter :has_session_info, :except => [:index, :choose_event, :set_event]

  def index
    if session[:current_site]
      redirect_to :controller => 'events', :action => 'choose_event'
    else 
      begin 
        response = token.get("/api/v1/sites", :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100});
      rescue => ex
        @error = ex
      else
        @sites = JSON.parse(response.body)["results"]
      end
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
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100})
      @events = JSON.parse(response.body)["results"]
    end
  end

  def set_event
    if params[:event] 
      session[:current_event] = params[:event]
      session[:current_event_name] = params[:name]
      redirect_to everyone_path
    else
      session[:current_event] = nil
      session[:current_event_name] = nil
      redirect_to choose_event_path
    end
  end

  def find_rsvp
    unless session[:current_event]
    end
    @event = session[:current_event]
  end

  def get_all
    e = Event.where(nation_id: session[:current_nation], eventNBID: session[:current_event]).first
    if e
      @rsvps = Rsvp.where(event_id: e.id).order( 'last_name ASC' )
    else
      create_cache

      e = Event.where(nation_id: session[:current_nation], eventNBID: session[:current_event]).first
      @rsvps = Rsvp.where(event_id: e.id).order( 'last_name ASC' )
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

    response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers)
    parsed = JSON.parse(response.body)
    rsvpListfromNB = []
    puts parsed
    if parsed['next']
      rsvpListfromNB << parsed["results"]
      currentpage = 1
      is_next = parsed['next']
      while is_next
        currentpage += 1
        pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage})
        response = JSON.parse(pagination_result.body)
        rsvpListfromNB << response['results']
        is_next = response['next']
      end
    elsif parsed["total_pages"]
      current_page = 1
      total_pages = parsed["total_pages"]
      rsvpListfromNB << parsed["results"]
      while total_pages >= current_page
        current_page += 1
        response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, params: {page: current_page})
        rsvpListfromNB << JSON.parse(response.body)["results"]
      end
    else 
      rsvpListfromNB << parsed["results"]
    end

    rsvpListfromNB.flatten!.each do |r|
      existentRSVP = Rsvp.find_by(event_id: event.id, rsvpNBID: r['id'], nation_id: session[:current_nation])
      if existentRSVP
        existentRSVP.update(attended: r['attended'])
      else
        response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
        person = JSON.parse(response.body)["person"]
        createNewRsvp(event.id, r['id'], person['id'], person['first_name'], person['last_name'], person['email'], r['guests_count'].to_i, r['canceled'], r['attended']) 
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
        if !flash
          flash[:success] = "RSVP found."
        end
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

    person = JSON.parse(response.body)["person"]
    rsvpObject = makeRSVP(nil, session[:current_event], person['id'].to_i, 0, "false", "false", "false", "true") 
    begin
      checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
    rescue => ex
        flash[:error] = "Either the RSVP already exists or there was an error."
        redirect_to :controller => 'events', :action => 'find_person', :email => params[:email], :last_name => params[:last_name],:first_name => params[:first_name], :phone => params[:phone], :mobile => params[:mobile]
    else
      flash[:success] = "#{params['first_name']} #{params['last_name']} successfully added and checked in."

      rsvpObject = JSON.parse(checkInResponse.body)["rsvp"]
      event = Event.find_by(eventNBID: session[:current_event].to_i)
      createNewRsvp(get_event.id, rsvpObject['id'].to_i, person['id'].to_i, person['first_name'], person['last_name'], person['email'], rsvpObject['guests_count'].to_i, to_boolean(rsvpObject['canceled']), to_boolean(rsvpObject['attended'])) 
      
      redirect_to :controller => 'events', :action => 'index'
    end
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

      main_rsvp = JSON.parse(checkInResponse.body)["rsvp"]
      existentRSVP = Rsvp.find_by(event_id: get_event.id, rsvpNBID: main_rsvp["id"].to_i, nation_id: session[:current_nation].to_i)
      existentRSVP.update(attended: true)
      flash[:success] = "#{existentRSVP.first_name} #{existentRSVP.last_name} checked in."

      if params[:guests].to_i > 0
        (params[:guests].to_i).times do |n|

          name = "guest_" + "#{n}"
          if(params[name])
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
                  guest_rsvp = JSON.parse(checkInResponse.body)["rsvp"]
                  Guest.create(
                    :eventNBID => session[:current_event].to_i, 
                    :plusoneNBID => guest_id.to_i,
                    :nationNBID => session[:current_nation],
                    :nation_name => "#{session[:current_site]}", 
                    :rsvpNBID => main_rsvp["id"].to_i
                  )

                  createNewRsvp(get_event.id, guest_rsvp["id"].to_i, guest_id.to_i, guest.first_name, guest.last_name, guest.email, 0, false, true)

                  flash[:success] = "#{existentRSVP.first_name} #{existentRSVP.last_name} and guests checked in."

                end
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

    rsvpresponse = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps", :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100 })
    rsvps = JSON.parse(rsvpresponse.body)["results"]

    rsvps.each do |rsvp|
      if rsvp['person_id'] == person
          rsvpFound = rsvp
      end
    end

    return rsvpFound

  end

  private 

  def createNewRsvp(eventID, rsvpNBID, personNBID, first_name, last_name, email, guests_count, canceled, attendance) 

    newRsvp = Rsvp.create(
      nation_id: session[:current_nation],
      event_id: eventID,
      rsvpNBID: rsvpNBID,
      personNBID: personNBID,
      first_name: first_name,
      last_name: last_name,
      email: email,
      guests_count: guests_count,
      canceled: canceled,
      attended: attendance
    )

    return newRsvp
  end

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