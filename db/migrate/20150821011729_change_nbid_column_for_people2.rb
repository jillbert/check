class ChangeNbidColumnForPeople2 < ActiveRecord::Migration
  def change
    rename_column :people, :NBID, :nbid
  end
end
