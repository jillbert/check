class AddNationIdToPersonModel < ActiveRecord::Migration
  def change
    add_column :people, :nation_id, :integer
  end
end
