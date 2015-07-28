module RsvpsHelper

	def makeRSVP(rsvp)

	  rsvpObject = {
	    "rsvp" => {
	      "id" => rsvp.rsvpNBID.to_i,
	      "event_id" => rsvp.event_id.to_i,
	      "person_id" => rsvp.personNBID.to_i,
	      "guests_count" => rsvp.guests_count.to_i,
	      "volunteer" => false,
	      "private" => false,
	      "canceled" => false,
	      "attended" => true,
	      "shift_ids" => []
	    }
	  }

	  begin
	  	checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
	  else 
	  	main_rsvp = JSON.parse(checkInResponse.body)["rsvp"]
	  	puts main_rsvp
	  	return true
	  end

	end

end
