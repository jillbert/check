class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :NBID
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :phone_number
      t.integer :rsvp_id

      t.timestamps
    end
  end
end
