class ImportNation
  @queue = :import_nation

  def self.perform(nation_id)
    nation = Nation.find(nation_id.to_i)
    nb_client = NationBuilder::Client.new(nation.name,
                                          nation.credentials.first.token, retries: 8)
    sites = nb_client.call(:sites, :index, limit: 1000)
    sites["results"].each do |site|
      slug = site["slug"]
      events = nb_client.call(:events, :index, site_slug: slug, limit: 1000)
      events['results'].each do |e|
        event = Event.import(e, nation.id)
        Rsvp.sync(event, slug)
      end
    end
    nation.users.each do |user|
      UserMailer.nation_import_done(user).deliver
    end
  end

end
