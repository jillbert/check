class AddPicToPerson < ActiveRecord::Migration
  def change
    add_column :people, :pic, :string, :default => nil
  end
end
