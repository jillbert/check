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
    nb_client = NationBuilder::Client.new(event.nation.name, event.nation.credentials.first.token, retries: 8)
    @rsvps = NationBuilder::Paginator.new(nb_client, nb_client.call(
                                                       :events,
                                                       :rsvps,
                                                       site_slug: site,
                                                       id: event.eventNBID
    ))
    unless @rsvps.body['results'].empty?
      while @rsvps
        @rsvps.body['results'].each do |rsvp|
          new_rsvp = Rsvp.find_or_create_by(rsvpNBID: rsvp['id'],
                                            event_id: event.id,
                                            nation_id: event.nation.id,
                                            person_id: Person.find_or_create_by(nbid: rsvp['person_id'], nation_id: event.nation.id).id)

          new_rsvp.assign_attributes(guests_count: rsvp['guests_count'],
                                     volunteer: rsvp['volunteer'],
                                     is_private: rsvp['private'],
                                     canceled: rsvp['canceled'],
                                     attended: rsvp['attended'],
                                     shift_ids: rsvp['shift_ids'],
                                     ticket_type: rsvp['ticket_type'],
                                     tickets_sold: rsvp['tickets_sold'])

          nb_person = nb_client.call(:people, :show, id: rsvp['person_id'])
          new_rsvp.person.assign_attributes(first_name: nb_person['person']['first_name'],
                                   last_name: nb_person['person']['last_name'],
                                   email: nb_person['person']['email'],
                                   phone_number: nb_person['person']['phone'],
                                   work_phone_number: nb_person['person']['work_phone_number'],
                                   mobile: nb_person['person']['mobile'])

          new_rsvp.save if new_rsvp.changed?
          new_rsvp.person.save if new_rsvp.person.changed?
        end
        @rsvps = (@rsvps.next if @rsvps.next?)
      end
    end
  end

  def self.letters(rsvps)
    letters = rsvps.map { |rsvp| rsvp.person.last_name[0].upcase.strip unless rsvp.person.nil? }
    letters.sort_by!(&:downcase) unless letters.empty? || letters.nil?
    letters = letters.uniq
  end

  def self.import(r, event, p_id, n_id)
    rsvp = Rsvp.find_or_create_by(
      event_id: event,
      rsvpNBID: r['id'].to_i,
      person_id: p_id,
      nation_id: n_id
    )

    rsvp.update(
      guests_count: r['guests_count'].to_i,
      canceled: r['canceled'],
      volunteer: r['volunteer'],
      shift_ids: r['shift_ids'].to_a,
      attended: r['attended']
    )

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
