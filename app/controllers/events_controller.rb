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
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100, starting: 14.days.ago.to_s})
      parsed = JSON.parse(response.body)
      events = []
      if parsed['next']
        events << parsed["results"]
        currentpage = 1
        is_next = parsed['next']
        while is_next
          currentpage += 1
          pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage})
          response = JSON.parse(pagination_result.body)
          events << response['results']
          is_next = response['next']
        end

      elsif parsed["total_pages"]
        current_page = 1
        total_pages = parsed["total_pages"]
        events << parsed["results"]
        while total_pages >= current_page
          current_page += 1
          response = token.get(token_get_path, :headers => standard_headers, params: {page: current_page, per_page: 100, limit: 100,starting: 14.days.ago.to_s})
          events << JSON.parse(response.body)["results"]
        end
      else 
        events << parsed["results"]
      end

      events.flatten!

      @current_events = Hash[events.select { |e| Time.zone = e['time_zone'] if e['start_time'] > 1.day.ago }.group_by { |e| e['start_time'].to_datetime.strftime("%B %Y") }.to_a.reverse]

      @past_events = Hash[events.select { |e| Time.zone = e['time_zone'] if e['start_time'] < 1.day.ago }.group_by { |e| e['start_time'].to_datetime.strftime("%B %Y") }.to_a.reverse]

    else
      redirect_to choose_site_path
    end
  end

  def set_event

    if params[:event]
      token_get_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + params[:event]
      response = token.get(token_get_path, :headers => standard_headers, :params => { page: 1, per_page: 100, limit: 100})
      event = JSON.parse(response.body)['event']

      token_put_path = '/api/v1/sites/' + session[:current_site] + '/pages/events/' + params[:event]
      puts clean_event_json(event)
      response = token.put(token_put_path, :headers => standard_headers, :body => clean_event_json(event))

      session[:current_event] = Event.import(event, current_user.nation.id).id
      
      redirect_to rsvps_path
    else
      redirect_to choose_event_path
    end
    
  end

  def sync_status
    @event = Event.find(params[:event_id])
    respond_to do |format|
      format.json { render :json => {:sync_status => @event.sync_status, :sync_percent => @event.sync_percent} }
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.rsvps.destroy_all
    @event.destroy
    session[:current_event] = nil
    redirect_to choose_event_path
  end

end