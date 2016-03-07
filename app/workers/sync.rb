class Sync

  # include ApplicationHelper
  # include RsvpsHelper
  # include PeopleHelper

  @queue = :sync_queue

  def self.perform(event_id, site_slug, credential_id)
    @current_event = Event.find(event_id)
    @current_nation = @current_event.nation
    @current_site = site_slug
    @token = Credential.find_by_id(credential_id).access_token

    create_cache
  end

  def self.get_rsvps
    error = false

    begin
      response = @token.get("/api/v1/sites/#{@current_site}/pages/events/#{@current_event.eventNBID}/rsvps/", :params => {per_page: 100, limit: 100}, :headers => { "Accept" => "application/json", "Content-Type" => "application/json" })
    rescue => ex
      error = true
    else
      parsed = JSON.parse(response.body)
      rsvpListfromNB = []

      # This is due different pagination rules implemented by NationBuilder
      
      if parsed['next']
        rsvpListfromNB << parsed["results"]
        currentpage = 1
        is_next = parsed['next']
        while is_next
          
          currentpage += 1
          
          begin
            pagination_result = @token.get(is_next, :headers => { "Accept" => "application/json", "Content-Type" => "application/json" }, :params => { token_paginator: currentpage, per_page: 100, limit: 100})
          rescue => ex
            error = true
            is_next = nil
          else
            response = JSON.parse(pagination_result.body)
            rsvpListfromNB << response['results']
            is_next = response['next']
          end

        end

      elsif parsed["total_pages"]
        current_page = 1
        total_pages = parsed["total_pages"]
        rsvpListfromNB << parsed["results"]
        while total_pages >= current_page
          current_page += 1
          begin
            response = @token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => { "Accept" => "application/json", "Content-Type" => "application/json" }, params: {page: current_page, per_page: 100, limit: 100})
          rescue => ex
            error = true
            total_pages = 0
          else
            rsvpListfromNB << JSON.parse(response.body)["results"]
          end
        end
      else 
        rsvpListfromNB << parsed["results"]
      end
    end

    if error
      return "error"
    else
      return rsvpListfromNB.flatten!
    end
  end

  def self.get_person(r)
    begin
      response = @token.get("/api/v1/people/#{r['person_id']}", :headers => { "Accept" => "application/json", "Content-Type" => "application/json" })
    rescue => ex
      return "error"
    else
      return JSON.parse(response.body)["person"]
    end
  end


  def self.create_cache

    rsvps = get_rsvps

    if rsvps != "error"

      total = rsvps.count
      error = 0

      rsvps.each_with_index do |r, index| 
        person = Person.find_by(nbid: r['person_id'].to_i, nation_id: @current_nation.id)
        
        if !person
          nbPerson = get_person(r)
          if nbPerson != "error"
            person = Person.import(nbPerson, @current_nation.id)
          else
            error += 1
          end
        end

        if person
          rsvp = Rsvp.import(r, @current_event.id, person.id, @current_nation.id)
        end

        percent = (index.to_f/total) * 100
        @current_event.update_attributes(sync_percent: percent.to_i)
      end

      if error > 0
        
        if error > 1
          errorString = "#{error} rsvps"
        else
          errorString = "#{error} rsvp"
        end

        sync_status = "Complete. However, NationBuilder did not allow Check to import #{errorString}."
      else
        sync_status = "Complete."
      end

    else
      sync_status = "Could not complete. There was a problem connecting to NationBuilder."
    end

    @current_event.update_attributes(sync_status: sync_status)

  end

end