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

end
