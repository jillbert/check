module RsvpsHelper

  def send_rsvp_to_nationbuilder(rsvp)

    rsvpObject = rsvp.to_rsvp_object
    if rsvpObject["rsvp"].has_key?("id")
      begin
        checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
        checked_in = JSON.parse(checkInResponse.body)["rsvp"]
      rescue => ex
        return {status: false, error: ex}
      else
        return {status: true, id: checked_in["id"].to_i }
      end

    else

      begin
        checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
      rescue => ex
        return { status: false, error: ex }
      else
        checked_in = JSON.parse(checkInResponse.body)["rsvp"]
        return {status: true, id: checked_in["id"].to_i }
      end

    end

  end

	def create_cache

	  response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers)
	  parsed = JSON.parse(response.body)
	  rsvpListfromNB = []

	  # This is due different pagination rules implemented by NationBuilder
	  
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
	      response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers, params: {page: current_page})
	      rsvpListfromNB << JSON.parse(response.body)["results"]
	    end
	  else 
	    rsvpListfromNB << parsed["results"]
	  end

	  rsvpListfromNB.flatten!.each do |r|
      rsvp = Rsvp.import(r, session[:current_nation], @current_event.id)

      response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
      person = Person.import(JSON.parse(response.body)["person"], rsvp.id)

	  end
	end

end