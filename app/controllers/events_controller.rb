class EventsController < ApplicationController

include ApplicationHelper
include EventsHelper

before_filter :has_credential?

  def choose_site
    if session[:current_site]
      session[:current_site] = nil
      session[:current_event] = nil
    end

    begin 
      response = token.get("/api/v1/sites", :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100});
    rescue => ex
      @error = ex
    else
      @sites = JSON.parse(response.body)["results"]
    end
  end


  def choose_event
    if params[:site]
      session[:current_site] = params[:site]
    end
    if session[:current_site]
      token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events'
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100})
      @events = JSON.parse(response.body)["results"]
    else
      redirect_to choose_site_path
    end
  end

  def set_event

    if params[:event]
      session[:current_event] = params[:event]
      session[:current_event_name] = params[:name]

      begin
        token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + session[:current_event]
        response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100})
      else 
        event = JSON.parse(response.body)
        if event['event']['rsvp_form']['address'] == "required"
          event['event']['rsvp_form']['address'] = "optional"
          event['event']['status'] = "published"
          token_put_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + session[:current_event]
          response = token.put(token_put_path, :headers => standard_headers, :body => event.to_json )
        end
        @event = Event.find_or_create_by(nation_id: session[:current_nation], eventNBID: session[:current_event])
      end

      redirect_to rsvps_path
    else
      redirect_to choose_event_path
    end
    
  end

 

  private 

  def event_params
    params.require(:event).permit(:nation_id, :eventNBID)
  end

end