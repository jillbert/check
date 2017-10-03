class Event < ActiveRecord::Base
  has_many :rsvps
  belongs_to :nation, inverse_of: :events

  def self.import(nb, session_nation)
    event = find_or_create_by(
      nation_id: session_nation,
      eventNBID: nb['id'].to_i
    )

    event.update(
      name: nb['name'],
      start_time: nb['start_time'].to_datetime,
      end_time: nb['end_time'].to_datetime,
      time_zone: nb['time_zone']
    )

    event
  end

  def attended(rsvp)
    rsvps.where(host_id: rsvp.id, attended: true).count
  end

  def to_local_time
    start_time.in_time_zone(time_zone).strftime('%B %e, %Y at %l%P %Z')
  end
end
