module EventsHelper
  def new_site
    session[:current_site] = nil
    session[:current_event] = nil

    redirect_to controller: 'events', action: 'choose_site'
  end

  def new_event
    session[:current_event] = nil
    redirect_to controller: 'events', action: 'choose_event'
  end

  def venue_hash(event_from_nb)
    {}.tap do |v|
      v['name'] = event_from_nb['venue']['name']
      v['address'] = {
        'address1' => event_from_nb['venue']['address']['address1'],
        'address2' => event_from_nb['venue']['address']['address2'],
        'address3' => event_from_nb['venue']['address']['address3'],
        'city' => event_from_nb['venue']['address']['city'],
        'county' => event_from_nb['venue']['address']['county'],
        'state' => event_from_nb['venue']['address']['state'],
        'country_code' => event_from_nb['venue']['address']['country_code'],
        'zip' => event_from_nb['venue']['address']['zip'],
        'lat' => event_from_nb['venue']['address']['lat'],
        'lng' => event_from_nb['venue']['address']['lng'],
        'fips' => event_from_nb['venue']['address']['fips']
      }
    end
  end

  def event_hash(event_from_nb, venue)
    {
      'event' =>
      {
        'id' => event_from_nb['id'],
        'slug' => event_from_nb['slug'],
        'path' => event_from_nb['path'],
        'status' => 'published',
        'site_slug' => event_from_nb['site_slug'],
        'name' => event_from_nb['name'],
        'headline' => event_from_nb['headline'],
        'title' => event_from_nb['title'],
        'excerpt' => event_from_nb['excerpt'],
        'author_id' => event_from_nb['author_id'],
        'published_at' => event_from_nb['published_at'],
        'external_id' => event_from_nb['external_id'],
        'tags' => event_from_nb['tags'],
        'intro' => event_from_nb['intro'],
        'calendar_id' => event_from_nb['calendar_id'],
        'start_time' => event_from_nb['start_time'],
        'end_time' => event_from_nb['end_time'],
        'time_zone' => event_from_nb['time_zone'],
        'rsvp_form' => {
          'phone' => 'optional',
          'address' => 'optional',
          'allow_guests' => event_from_nb['rsvp_form']['allow_guests'],
          'accept_rsvps' => event_from_nb['rsvp_form']['accept_rsvps'],
          'gather_volunteers' => event_from_nb['rsvp_form']['gather_volunteers']
        },
        'capacity' => event_from_nb['capacity'],
        'show_guests' => event_from_nb['show_guests'],
        'venue' => venue,
        'autoresponse' => event_from_nb['autoresponse'],
        'shifts' => event_from_nb['shifts']
      }
    }
  end

  def clean_event_json(event_from_nb)
    venue = if event_from_nb['venue']['address']
              venue_hash(event_from_nb)
            else
              { 'name' => event_from_nb['venue']['name'] }
            end

    event_hash(event_from_nb, venue).to_json
  end
end
