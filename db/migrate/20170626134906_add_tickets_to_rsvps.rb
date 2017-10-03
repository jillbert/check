class AddTicketsToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :ticket_type, :string
    add_column :rsvps, :tickets_sold, :integer
  end
end
