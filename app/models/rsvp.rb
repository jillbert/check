class Rsvp < ActiveRecord::Base
	
	
	# attr_accessor :rsvp_id, :person_id, :event_id, :guests_count, :canceled, :attended, :volunteer, :is_private, :shift_ids

	belongs_to :event
	belongs_to :nation
	
	has_one :person
	accepts_nested_attributes_for :person

	has_many :guests, class_name: "Rsvp", foreign_key: "host_id"
	belongs_to :host, class_name: "Rsvp"

	# validate :is_unique_rsvp

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

	def rsvpObject
		rsvpObject = {
		  "rsvp" => {
		    "id" => self.rsvpNBID.to_i,
		    "event_id" => self.event_id.to_i,
		    "person_id" => self.personNBID.to_i,
		    "guests_count" => self.guests_count.to_i,
		    "volunteer" => false,
		    "private" => false,
		    "canceled" => false,
		    "attended" => true,
		    "shift_ids" => []
		  }
		}
	end

	def to_rsvp_object 

		rsvpObject = {
		  "rsvp" => {
		    "event_id" => self.event_id.to_i,
		    "person_id" => self.person.nbid.to_i,
		    "guests_count" => self.guests_count.to_i,
		    "volunteer" => self.volunteer,
		    "private" => self.is_private,
		    "canceled" => self.canceled,
		    "attended" => true,
		    "shift_ids" => self.shift_ids
		  }
		}

		if self.rsvpNBID
			rsvpObject["rsvp"]["id"] = self.rsvpNBID.to_i
		end

		return rsvpObject

	end

	def is_unique_rsvp
		rsvps = Rsvp.where(event_id: self.event_id)
		if rsvps
			rsvps.each do |r|
				if r.person.nbid == self.person.nbid
					self.errors.add(:rsvp, 'is not unique')
					break
				end
			end
		end
	end

end
