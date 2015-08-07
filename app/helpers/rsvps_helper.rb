module RsvpsHelper

	def new_rsvp(person_params)
		person_object = {
		  :person => {
		    :first_name => person_params[:first_name],
		    :last_name => person_params[:last_name],
		    :email => person_params[:email],
		    :recruiter_id => person_params[:host_id].to_i
		  }
		}

		begin
		  response = token.put("/api/v1/people/push", :headers => standard_headers, :params => person_object)
		rescue => ex
			puts ex.inspect
		else
			person = (JSON.parse(response["person"]))
		end

		if person
			rsvp =
			{
			  "rsvp" => {
			  	"event_id" => session[:current_event].to_i,
			    "person_id" => person["id"].to_i,
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
			else
				check_in = JSON.parse(checkInResponse.body)["rsvp"]
				return Rsvp.create(
					rsvpNBID: check_in["id"].to_i,
					event_id: check_in["event_id"].to_i,
					person_id: person["id"].to_i,
					first_name: person["first_name"],
					last_name: person["last_name"],
					email: person["email"],
					guests_count: check_in["guests_count"].to_i,
					volunteer: check_in["volunteer"],
					is_private: check_in["private"],
					canceled: check_in["canceled"],
					attended: check_in["attended"],
					shift_ids: check_in["shift_ids"],
					)
			end
		end
	end

	def makeRSVP(rsvp)

	  rsvpObject = {
	    "rsvp" => {
	      "id" => rsvp.rsvpNBID.to_i,
	      "event_id" => rsvp.event_id.to_i,
	      "person_id" => rsvp.personNBID.to_i,
	      "guests_count" => rsvp.guests_count.to_i,
	      "volunteer" => rsvp.volunteer,
	      "private" => rsvp.is_private,
	      "canceled" => rsvp.canceled,
	      "attended" => true,
	      "shift_ids" => rsvp.shift_ids
	    }
	  }

	  begin
	  	checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
	  	puts checkInResponse.inspect
	  else 
	  	main_rsvp = JSON.parse(checkInResponse.body)["rsvp"]
	  	puts main_rsvp
	  	return true
	  end

	end

end
