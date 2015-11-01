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
      events = JSON.parse(response.body)["results"]

      @current_events = Hash[events.select { |e| e if e['start_time'].to_date.future? }.group_by { |e| e['start_time'].to_datetime.strftime("%B %Y") }.to_a.reverse]

      @past_events = Hash[events.select { |e| e if e['start_time'].to_date.past? }.group_by { |e| e['start_time'].to_datetime.strftime("%B %Y") }.to_a.reverse]

    else
      redirect_to choose_site_path
    end
  end

  def set_event

    if params[:event]
      begin
        token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + params[:event]
        response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100})
      else 
        event = JSON.parse(response.body)['event']
        if event['rsvp_form']['address'] == "required"
          event['rsvp_form']['address'] = "optional"
          event['status'] = "published"
          token_put_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + params[:event]
          response = token.put(token_put_path, :headers => standard_headers, :body => event.to_json )
        end
        session[:current_event] = Event.import(event, current_user.nation.id).id
      end

      redirect_to rsvps_path
    else
      redirect_to choose_event_path
    end
    
  end

end