class Rsvp

	attr_accessor :rsvp_id,:person_id, :event_id, :guests_count, :canceled, :attended, :volunteer, :is_private, :shift_ids

	def self.from_hash(hash)
	  new.tap do |rsvp|
	  	rsvp.rsvp_id = hash.fetch("id")
	    rsvp.person_id = hash.fetch("person_id")
	    rsvp.event_id = hash.fetch("event_id")
	    rsvp.guests_count = hash.fetch("guests_count")
	    rsvp.volunteer = hash.fetch("volunteer")
	    rsvp.is_private = hash.fetch("private")
	    rsvp.canceled = hash.fetch("canceled")
	    rsvp.attended = hash.fetch("attended")
	    rsvp.shift_ids = hash.fetch("shift_ids")
	  end
	end

end
