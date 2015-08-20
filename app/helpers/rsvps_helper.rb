module RsvpsHelper

	def send_rsvp_to_nationbuilder(rsvp)

		rsvpObject = rsvp.to_rsvp_object
		puts rsvpObject
		if rsvpObject["rsvp"].has_key?("id")
			begin
				checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
			else 
				checked_in = JSON.parse(checkInResponse.body)["rsvp"]
			end
		else
			begin
			  checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => rsvpObject.to_json)
			rescue => ex
				response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers)
				parsed = JSON.parse(response.body)["results"]
				checked_in = parsed.find { |r| r if r["person_id"].to_i == rsvp.person.nbid }			
				if !checked_in && parsed['next']
				  currentpage = 1
				  is_next = parsed['next']
				  while !checked_in && is_next
				    currentpage += 1
				    pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage})
				    response = JSON.parse(pagination_result.body)["results"]
				    checked_in = response.find { |r| r if r["person_id"].to_i == rsvp.person.nbid }			
				    is_next = response['next']
				  end
				end
			else
				checked_in = JSON.parse(checkInResponse.body)["rsvp"]
			end

		end

		return checked_in["id"].to_i


	end

end


# def new_rsvp(person_params)

# 	person_object = {
# 	  :person => {
# 	    :first_name => person_params[:first_name],
# 	    :last_name => person_params[:last_name],
# 	    :email => person_params[:email],
# 	    :recruiter_id => person_params[:host_id].to_i
# 	  }
# 	}

# 	begin
# 	  response = token.put("/api/v1/people/push/", :headers => standard_headers, :body => person_object.to_json)
# 	rescue => ex
# 		puts ex
# 	else
# 		person = JSON.parse(response.body)["person"]
# 	end

# 	if person
# 		rsvp_exists = Rsvp.find_by(personNBID: person["id"].to_i)
# 	end

# 	if person && !rsvp_exists
# 		rsvp =
# 		{
# 		  "rsvp" => {
# 		  	"event_id" => session[:current_event].to_i,
# 		    "person_id" => person["id"].to_i,
# 		    "guests_count" => 0,
# 		    "volunteer" => false,
# 		    "private" => false,
# 		    "canceled" => false,
# 		    "attended" => true,
# 		    "shift_ids" => []
# 		  }
# 		}
		
# 		begin
# 		  checkInResponse = token.post("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers, :body => rsvp.to_json)
# 		rescue => ex
# 			response = token.get("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/", :headers => standard_headers)
# 			parsed = JSON.parse(response.body)["results"]
# 			checked_in = parsed.find { |rsvp| rsvp if rsvp["person_id"].to_i == person["id"].to_i }			
# 			if !checked_in && parsed['next']
# 			  currentpage = 1
# 			  is_next = parsed['next']
# 			  while !checked_in && is_next
# 			    currentpage += 1
# 			    pagination_result = token.get(is_next, :headers => standard_headers, :params => { token_paginator: currentpage})
# 			    response = JSON.parse(pagination_result.body)["results"]
# 			    checked_in = response.find { |rsvp| rsvp if rsvp["person_id"].to_i == person["id"].to_i }			
# 			    is_next = response['next']
# 			  end
# 			end
# 		else
# 			checked_in = JSON.parse(checkInResponse.body)["rsvp"]
# 		end

# 		return Rsvp.create(
# 			rsvpNBID: checked_in["id"].to_i,
# 			event_id: checked_in["event_id"].to_i,
# 			personNBID: person["id"].to_i,
# 			first_name: person["first_name"],
# 			last_name: person["last_name"],
# 			email: person["email"],
# 			guests_count: checked_in["guests_count"].to_i,
# 			volunteer: checked_in["volunteer"],
# 			is_private: checked_in["private"],
# 			canceled: checked_in["canceled"],
# 			attended: checked_in["attended"],
# 			shift_ids: checked_in["shift_ids"],
# 			)

# 	elsif rsvp_exists
# 		return rsvp_exists
# 	end
# end



	# def nationbuilder_person
	# 	person_object = {
	# 	  :person => {
	# 	    :first_name => params[:rsvp][:first_name],
	# 	    :last_name => params[:rsvp][:last_name],
	# 	    :email => params[:rsvp][:email],
	# 	    :recruiter_id => params[:rsvp][:host_id].to_i
	# 	  }
	# 	}
	# 	begin
	# 	  response = token.put("/api/v1/people/push/", :headers => standard_headers, :body => person_object.to_json)
	# 	rescue => ex
	# 		puts ex
	# 	else
	# 		person = JSON.parse(response.body)["person"]
	# 	end
	# end

	# def nationbuilder_rsvp(person_from_nb)
	# 	rsvp =
	# 	{
	# 	  "rsvp" => {
	# 	  	"event_id" => params[:rsvp][:event_id].to_i,
	# 	    "person_id" => person_from_nb["id"].to_i,
	# 	    "guests_count" => params[:rsvp][:guests_count].to_i,
	# 	    "volunteer" => to_boolean(params[:rsvp][:volunteer]),
	# 	    "private" => to_boolean(params[:rsvp][:private]),
	# 	    "canceled" => to_boolean(params[:rsvp][:canceled]),
	# 	    "attended" => true,
	# 	    "shift_ids" => params[:rsvp][:shift_ids].to_a
	# 	  }
	# 	}
	# end

	# def makeRSVP(rsvp)

	#   rsvpObject = {
	#     "rsvp" => {
	#       "id" => rsvp.rsvpNBID.to_i,
	#       "event_id" => rsvp.event_id.to_i,
	#       "person_id" => rsvp.person.nbid.to_i,
	#       "guests_count" => rsvp.guests_count.to_i,
	#       "volunteer" => rsvp.volunteer,
	#       "private" => rsvp.is_private,
	#       "canceled" => rsvp.canceled,
	#       "attended" => true,
	#       "shift_ids" => rsvp.shift_ids
	#     }
	#   }

	#   begin
	#   	checkInResponse = token.put("/api/v1/sites/#{session[:current_site]}/pages/events/#{session[:current_event]}/rsvps/#{rsvp.rsvpNBID}", :headers => standard_headers, :body => rsvpObject.to_json)
	#   	puts checkInResponse.inspect
	#   else 
	#   	main_rsvp = JSON.parse(checkInResponse.body)["rsvp"]
	#   	puts main_rsvp
	#   	return true
	#   end

	# end