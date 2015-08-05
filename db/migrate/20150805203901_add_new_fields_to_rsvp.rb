class AddNewFieldsToRsvp < ActiveRecord::Migration
  def change
  	add_column :rsvps, :volunteer, :boolean, :default => nil
  	add_column :rsvps, :is_private, :boolean, :default => nil
  	add_column :rsvps, :shift_ids, :string, array: true, default: []
  	add_column :rsvps, :host_id, :integer
  end
end
