class ImportNation
  @queue = :import_nation

  def self.perform(nation_id, site_slug)
    nation = Nation.find(nation_id.to_i)
    nb_client = NationBuilder::Client.new(nation.name,
                                          nation.credentials.first.token, retries: 8)
    sites = nb_client.call(:sites, :index, limit: 1000)
    sites["results"].each do |site|
      slug = site["slug"]
      events = nb_client.call(:events, :index, site_slug: slug, limit: 1000)
      events.each do |event|
        event = Event.find_or_create_by(nation_id: nation.id, eventNBID: event["id"])
      end
    end
  end

end
