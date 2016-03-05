class AddSyncInfoToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sync_status, :string, :default => "complete"
    add_column :events, :sync_percent, :integer, :default => 100
    add_column :events, :sync_date, :datetime
  end
end
