class SwitchPersonRsvpRelationship < ActiveRecord::Migration
  def change
    remove_column :people, :rsvp_id
    add_column :rsvps, :person_id, :integer
  end
end
