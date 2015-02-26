class AddIDtoNation < ActiveRecord::Migration
  def change
    add_column :nations, :user_id, :integer, :default => nil
  end
end
