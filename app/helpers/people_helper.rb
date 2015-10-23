module PeopleHelper 

	def send_person_to_nationbuilder(person)
		begin
		  response = token.put("/api/v1/people/push/", :headers => standard_headers, :body => person.to_person_object)
		rescue => ex
      return {status: false, error: ex}
		else
		  nbperson = JSON.parse(response.body)["person"]
      return {status: true, id: nbperson["id"].to_i}
		end

	end
end