class AddInfoToEvent < ActiveRecord::Migration
  def change
    add_column :events, :name, :string
    add_column :events, :start_time, :datetime
    add_column :events, :end_time, :datetime
    add_column :events, :time_zone, :string  
  end
end
