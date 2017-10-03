class RemoveUserIdFromNation < ActiveRecord::Migration
  def change
    remove_column :nations, :user_id
  end
end
