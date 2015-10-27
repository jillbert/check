class RemoveGuestTable < ActiveRecord::Migration
  def change
    drop_table :guests
    remove_column :rsvps, :personNBID
    remove_column :rsvps, :first_name
    remove_column :rsvps, :last_name
    remove_column :rsvps, :email
  end
end
