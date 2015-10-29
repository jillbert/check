module PeopleHelper 

	def send_person_to_nationbuilder(person)
		begin

			if person.nbid
		  	response = token.put("/api/v1/people/#{person.nbid}/", :headers => standard_headers, :body => person.to_person_object)
		  else
		  	response = token.put("/api/v1/people/push/", :headers => standard_headers, :body => person.to_person_object)
		  end
		rescue => ex
      return {status: false, error: ex}
		else
		  nbperson = JSON.parse(response.body)["person"]
      return {status: true, person: nbperson}
		end

	end

end