class MoveNationAssociationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nation_id, :integer
  end
end
