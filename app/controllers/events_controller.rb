class EventsController < ApplicationController

include ApplicationHelper

  def index
    if session[:current_site]
      redirect_to :controller => 'events', :action => 'choose_event'
    else 
      response = token.get("/api/v1/sites", :headers => standard_headers, :params => { page: 1, per_page: 100});
      @sites = JSON.parse(response.body)["results"]
    end

    # if params[:event_id]
    #   @event = params[:event_id]
    #   @first_name = params[:first_name]
    #   @last_name = params[:last_name]
    # end

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
    complete = false

    if params[:rsvp_id]
      rsvpObject = makeRSVP(params[:rsvp_id], event_id, params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    else
      rsvpObject = makeRSVP(nil, event_id, params[:person_id], params[:guests_count], params[:volunteer], params[:private], params[:canceled], params[:attended]) 
    end

    begin

      if params[:rsvp_id]
        checkInResponse = token.put("/api/v1/sites/josho/pages/events/#{event_id}/rsvps/#{params[:rsvp_id]}", :headers => standard_headers, :body => rsvpObject.to_json)
      else
        checkInResponse = token.post("/api/v1/sites/josho/pages/events/#{event_id}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
      end

    rescue => ex

      flash[:error] = ex
      complete = false

    else

      main_rsvp_id = JSON.parse(checkInResponse.body)["rsvp"]["id"]

      if params[:guests].to_i > 0
        (params[:guests].to_i).times do |n|
          if stop = false
            name = "guest_" + "#{n}"
            inputted_guest = params[name.to_sym].to_hash
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
                stop = true
                complete = false
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
                    checkInResponse = token.post("/api/v1/sites/josho/pages/events/#{event_id}/rsvps/", :headers => standard_headers, :body => putParams.to_json)
                rescue => ex 
                  flash[:error] = ex
                  stop = true
                  complete = false
                  puts stop
                else
                  Guest.create(
                    :eventNBID => event_id.to_i, 
                    :plusoneNBID => guest_id.to_i,
                    :nationNBID => session[:current_nation],
                    :nation_name => "josho", 
                    :rsvpNBID => main_rsvp_id.to_i
                  )

                  complete = true
                end
              end
            else 
              complete = false
              stop = true
              flash[:error] = "Please complete all fields for #{inputted_guest["first_name"]}"
            end
          end
        end
      else
        complete = true
      end
    end

    if complete = true
      redirect_to :controller => 'events', :action => 'index', :event_id => event_id
    end

  end

  def findRSVP(event, person)
    rsvpFound = nil

    rsvpresponse = token.get("/api/v1/sites/josho/pages/events/#{event}/rsvps", :headers => standard_headers, :params => { page: 1, per_page: 100 })
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

  def makeRSVP(rsvp, event_id, person_id, guests_count, volunteer, isPrivate, canceled, attended)

    if rsvp
      putParams = {
        "rsvp" => {
          "id" => rsvp.to_i,
          "event_id" => event_id.to_i,
          "person_id" => person_id.to_i,
          "guests_count" => guests_count.to_i,
          "volunteer" => to_boolean(volunteer),
          "private" => to_boolean(isPrivate),
          "canceled" => to_boolean(canceled),
          "attended" => to_boolean(attended),
          "shift_ids" => []
        }
      }
    else
      putParams = {
        "rsvp" => {
          "event_id" => event_id.to_i,
          "person_id" => person_id.to_i,
          "guests_count" => guests_count.to_i,
          "volunteer" => to_boolean(volunteer),
          "private" => to_boolean(isPrivate),
          "canceled" => to_boolean(canceled),
          "attended" => to_boolean(attended),
          "shift_ids" => []
        }
      }
    end

    return putParams

  end

  def createMatchParams(first_name, last_name, email, phone, mobile)
    params = {
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :phone => phone,
      :mobile => mobile
    }

    params.delete_if { |k, v| v.empty? }

    return params
  
  end

  def new_site
    session[:current_site] = nil
    session[:current_event] = nil
    redirect_to :controller => "events", :action => "index"
  end

  def new_event
    session[:current_event] = nil
    redirect_to :controller => "events", :action => "choose_event"
  end

end