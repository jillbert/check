class Rsvp < ActiveRecord::Base
	
	belongs_to :event
	belongs_to :nation
	
	has_one :person
	accepts_nested_attributes_for :person
	validates_associated :person
	
	has_many :guests, class_name: "Rsvp", foreign_key: "host_id"
	belongs_to :host, class_name: "Rsvp"

	def self.import(r, nation, event)

		rsvp = Rsvp.find_or_create_by(
		  nation_id: nation,
		  event_id: event,
		  rsvpNBID: r['id'].to_i
		)
		
		rsvp.update(
			guests_count: r['guests_count'].to_i,
			canceled: r['canceled'],
			volunteer: r['volunteer'],
			shift_ids: r['shift_ids'].to_a,
			attended: r['attended']
			)

		return rsvp

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

end
