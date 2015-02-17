class AddNbiDtoRsvPs < ActiveRecord::Migration
  def change
    add_column :rsvps, :rsvpNBID, :integer, :default => nil
  end
end
