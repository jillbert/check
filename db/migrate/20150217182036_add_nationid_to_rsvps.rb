class AddNationidToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :nation_id, :integer
  end
end
