class Rsvp < ActiveRecord::Base
  belongs_to :event
  belongs_to :person

  has_many :guests, class_name: 'Rsvp', foreign_key: 'host_id'
  belongs_to :host, class_name: 'Rsvp'

  def self.search(search)
    where('name LIKE ?', "%#{search}%")
    where('email LIKE ?', "%#{search}%")
  end

  def self.sync(event, site)
    nation = event.nation
    nb_client = NationBuilder::Client.new(nation.name,
                                          nation.credentials.first.token, retries: 8)
    rsvps = NationBuilder::Paginator.new(nb_client, nb_client.call(
                                                       :events,
                                                       :rsvps,
                                                       site_slug: site,
                                                       id: event.eventNBID,
                                                       limit: 100))
    unless rsvps.body['results'].empty?
      while rsvps
        rsvps.body['results'].each do |rsvp|

          person = Person.find_by(nation_id: nation.id, nbid: rsvp["person_id"])

          if person.nil?
            nb_person = nb_client.call(:people,
                                     :show,
                                     id: rsvp['person_id'])
            person = Person.import(nb_person["person"], nation.id)
          end

          Rsvp.import(rsvp,
                      event.id,
                      person.id,
                      nation.id)

        end
        rsvps = (rsvps.next if rsvps.next?)
      end
    end
  end

  def self.letters(last_names)
    letters = last_names.map { |name| name[0].upcase.strip unless name.nil? || name.empty? }
    letters = letters.compact
    letters.sort! unless letters.empty? || letters.nil?
    letters = letters.uniq
  end

  def additional_status
    if self.canceled
      "Canceled"
    elsif self.volunteer
      "Volunteer"
    end
  end

  def ticket_name
    first_name = self.person.first_name
    last_name = self.person.last_name
    if !first_name.empty? && !last_name.empty?
      @name = "#{last_name}, #{first_name}"
    elsif !last_name.empty?
      @name = last_name
    elsif !first_name.empty?
      @name = first_name
    else
      @name = "Guest"
    end
    @name.titleize
  end

  def self.import(r, e_id, p_id, n_id)
    rsvp = Rsvp.find_or_create_by(
      event_id: e_id,
      rsvpNBID: r['id'].to_i,
      person_id: p_id,
      nation_id: n_id
    )

    rsvp.assign_attributes(
      guests_count: r['guests_count'].to_i,
      canceled: r['canceled'],
      volunteer: r['volunteer'],
      shift_ids: r['shift_ids'].to_a,
      attended: r['attended']
    )

    rsvp.save if rsvp.changed?

    rsvp
  end

  def self.create_new_rsvp(nation, event, p_id)
    Rsvp.new(
      nation_id: nation,
      event_id: event,
      person_id: p_id,
      guests_count: 0,
      canceled: false,
      volunteer: false,
      shift_ids: [],
      attended: true
    )
  end

  def to_rsvp_object(person)
    rsvpObject = {
      'rsvp' => {
        'event_id' => event_id.to_i,
        'person_id' => person.nbid.to_i,
        'guests_count' => guests_count.to_i,
        'volunteer' => volunteer,
        'private' => is_private,
        'canceled' => canceled,
        'attended' => attended,
        'shift_ids' => shift_ids
      }
    }

    rsvpObject['rsvp']['id'] = rsvpNBID.to_i if rsvpNBID

    rsvpObject
  end
end
