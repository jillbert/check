class UpdatePerson
  @queue = :update_person

  def self.perform(person_id)
    person = Person.find(person_id)
    nation = person.nation
    nb_client = NationBuilder::Client.new(nation.name,
                                          nation.credentials.first.token, retries: 8)

    nb_person = nb_client.call(:people,
                               :show,
                               id: person.nbid)
    Person.import(nb_person["person"], nation.id) if nb_person["person"]
  end

end
