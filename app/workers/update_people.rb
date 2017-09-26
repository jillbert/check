class UpdatePeople
  @queue = :update_people

  def self.perform(person)
    nation = person.nation
    nb_client = NationBuilder::Client.new(nation.name,
                                          nation.credentials.first.token, retries: 8)

    nb_person = nb_client.call(:people,
                               :show,
                               id: person.nbid)
    Person.import(nb_person["person"], nation.id)
  end

end
