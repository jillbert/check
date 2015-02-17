class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :nation_id
      t.integer :eventNBID

      t.timestamps
    end

    create_table :rsvps do |t|
      t.integer :event_id
      t.integer :personNBID
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :guests_count
      t.boolean :canceled
      t.boolean :attended

      t.timestamps
    end
  end
end
