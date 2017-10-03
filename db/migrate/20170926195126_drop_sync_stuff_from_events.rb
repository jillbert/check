class DropSyncStuffFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :sync_date
    remove_column :events, :sync_status
    remove_column :events, :sync_percent
  end
end
