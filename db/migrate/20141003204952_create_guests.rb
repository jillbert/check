class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.integer :nationNBID
      t.string :nation_name
      t.integer :eventNBID
      t.integer :rsvpNBID
      t.integer :plusoneNBID

      t.timestamps
    end
  end
end
