module RsvpsHelper

  def send_rsvp_to_nationbuilder(rsvp)

    rsvpObject = rsvp.to_rsvp_object
    puts rsvpObject
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
        begin
          response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{@current_event.eventNBID}/rsvps/", :headers => standard_headers)
        rescue => ex
          return { status: false, error: ex }
        else
        	puts response.body
          parsed = JSON.parse(response.body)
          checked_in = parsed['results'].find { |r| r if r["person_id"].to_i == rsvp.person.nbid }
          if !checked_in && parsed['next']
            currentpage = 1
            is_next = parsed['next']
            while !checked_in && is_next
              currentpage += 1
              begin
                pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage})
              rescue => ex
                return { status: false, error: ex }
              else
                response = JSON.parse(pagination_result.body)
                checked_in = response['results'].find { |r| r if r["person_id"].to_i == rsvp.person.nbid }     
                is_next = response['next']
              end
            end
          end
        end

        if checked_in
          return {status: true, id: checked_in["id"].to_i }
        else
          return { status: false, error: "Unknown error occured sending this RSVP to NationBuilder" }
        end

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
	    rsvp = Rsvp.find_by(event_id: @current_event.eventNBID, rsvpNBID: r['id'], nation_id: session[:current_nation])
	    if rsvp
	      rsvp.update(attended: r['attended'])
	    else
	      response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
	      person = JSON.parse(response.body)["person"]
	      rsvp = Rsvp.create(
	      	  nation_id: session[:current_nation],
	      	  event_id: @current_event.id,
	      	  rsvpNBID: r['id'].to_i,
	      	  guests_count: r['guests_count'].to_i,
	      	  canceled: r['canceled'],
	      	  attended: r['attended'],
	      	  volunteer: r['volunteer'],
	      	  shift_ids: r['shift_ids'].to_a,
	      	)

	      Person.create(
	        nbid: person['id'],
	        first_name: person["first_name"],
	        last_name: person["last_name"],
	        email: person["email"],
	        phone_number: person["phone"],
	        rsvp_id: rsvp.id
	      )
	    end
	  end
	end

end